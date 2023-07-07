import subprocess


def initialize():
    process = subprocess.Popen(
        ['terraform', 'init', '-no-color'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    process.communicate()
    return process.returncode


def apply():
    process = subprocess.Popen(
        ['terraform', 'apply', '-auto-approve', '-no-color'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return process.returncode, stdout, stderr


def destroy():
    process = subprocess.Popen(
        ['terraform', 'destroy', '-auto-approve', '-no-color'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return process.returncode


def output():
    process = subprocess.Popen(
        ['terraform', 'output', '-json', '-no-color'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return process.returncode, stdout, stderr
