import pytest
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import test_utils
import json


@pytest.fixture(scope='session')
def apply_changes():
    assert test_utils.initialize() == 0
    yield test_utils.apply()
    assert test_utils.destroy() == 0


@pytest.fixture
def outputs():
    code, out, err = test_utils.output()
    assert code == 0, err
    return json.loads(out)


def test_changes_have_successful_return_code(apply_changes):
    return_code = apply_changes[0]
    assert return_code == 0


def test_changes_should_have_no_errors(apply_changes):
    errors = apply_changes[2]
    assert errors == b''


def test_boundary_should_be_running(apply_changes, outputs):
    boundary_session = requests.Session()
    retries = Retry(total=30,
                    backoff_factor=1,
                    status_forcelist=[502, 503, 504])
    boundary_session.mount('http://', HTTPAdapter(max_retries=retries))
    response = boundary_session.get(
        "http://{}:9200/v1/auth-methods?scope_id=global".format(outputs.get('boundary_addr').get('value')))
    assert response.status_code == 200
