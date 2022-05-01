# This Makefile designed for invocation on a Windows machine using a Git Bash shell
# Uses python 3.8, pip 3.8, venv, 7zip, git bash emulator for windows
# The reason for using the lambda layer is to pin down the Lambda runtime, instead of using AWS's latest at runtime
default:
	echo
prepdirs:
	mkdir -p ./workspace/venv/layer
	mkdir -p ./workspace/output/layer
createVirtualEnv: clearenv prepdirs
	python -m venv ./workspace/venv
createlayer: createVirtualEnv
	./workspace/venv/Scripts/pip3.8.exe install -t ./workspace/venv/layer/python3 boto3
clearenv:
	rm -rf ./workspace/venv
ziplayer: createlayer
	7z a -r ./workspace/output/layer/lambdalayer.zip ./workspace/venv/layer