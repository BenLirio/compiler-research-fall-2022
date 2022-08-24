# IDA pro can not be build into build because it has a license.
# Instead, download pre-installed encrypted version and decrypt at runtime.

from os import path, system, makedirs
import pathlib
import urllib.request
import sys

assert len(sys.argv) >= 2

LOG_LEVEL = 0
KEY_FILE_NAME = sys.argv[1]
ARTIFACT_DOMAIN = "artifacts-compiler-research-fall-2022.s3-website-us-east-1.amazonaws.com"
IDA_ARTIFACT_NAME = "ida"

ARTIFACT_DIRECTORY = path.join('artifacts')

if not path.exists(ARTIFACT_DIRECTORY):
    makedirs(ARTIFACT_DIRECTORY)

def log(message, level):
    if LOG_LEVEL >= level:
        print(f"[ log level = {level} ] {message}")

def download_artifact(artifact_name):
    log(f"downloading '{artifact_name}'", 2)
    artifact_url = f"http://{ARTIFACT_DOMAIN}/{artifact_name}"
    dst_file_name = path.join(ARTIFACT_DIRECTORY, artifact_name)
    urllib.request.urlretrieve(artifact_url, dst_file_name)
    return dst_file_name

OPENSSL_ITER = 3 # Must match encryption iter
def decrypt(encrypted_file_name, key_file_name):
    log(f"decrypting '{encrypted_file_name}'", 2)
    assert pathlib.Path(encrypted_file_name).suffix == ".enc"
    file_name = path.splitext(encrypted_file_name)[0]
    system(f"openssl enc -d -aes-256-cbc -in {encrypted_file_name} -out {file_name} -kfile {key_file_name} -iter {OPENSSL_ITER}")
    return file_name

def unarchive(archived_file_name):
    log(f"unarchiving '{archived_file_name}'", 2)
    suffixes = pathlib.Path(archived_file_name).suffixes
    assert len(suffixes) == 2
    assert suffixes[0] == '.tar'
    assert suffixes[1] == '.gz'
    system(f"tar -xf {archived_file_name}")

def load_artifact(artifact_name, key_file_name):
    log(f"loading artifact '{artifact_name}'", 1)
    artifact_name_with_extensions  = '.'.join([artifact_name, 'tar', 'gz', 'enc'])
    encrypted_archived_artifact_file_name = download_artifact(artifact_name_with_extensions)
    archived_artifact_file_name = decrypt(encrypted_archived_artifact_file_name, key_file_name)
    unarchive(archived_artifact_file_name)

load_artifact(IDA_ARTIFACT_NAME, KEY_FILE_NAME)
