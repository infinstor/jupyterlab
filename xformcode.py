import os
import sys
import subprocess
import time

token = None
service = None
for x in range(1, len(sys.argv)):
    if (sys.argv[x].startswith('--token')):
        token = sys.argv[x][8:]
    elif (sys.argv[x].startswith('--service')):
        service = sys.argv[x][10:]

if (not token):
    raise Exception('insufficient parameters: token necessary')

if (not service):
    raise Exception('insufficient parameters: service name necessary')

cognito_username=os.getenv('COGNITO_USERNAME')
if (not cognito_username):
    raise Exception('need cognito_username')

cur_env = os.environ
if ('MLFLOW_TRACKING_URI' in cur_env):
    del cur_env['MLFLOW_TRACKING_URI']
if ('MLFLOW_EXPERIMENT_ID' in cur_env):
    del cur_env['MLFLOW_EXPERIMENT_ID']
if ('MLFLOW_EXPERIMENT_NAME' in cur_env):
    del cur_env['MLFLOW_EXPERIMENT_NAME']
if ('MLFLOW_RUN_ID' in cur_env):
    del cur_env['MLFLOW_RUN_ID']
subprocess.run(['/opt/conda/bin/jupyter-labhub', '--debug', '-y', '--no-browser', '--ip', '0.0.0.0', '--port', '8888', '--allow-root'],
    env=dict(cur_env,
        JUPYTERHUB_API_TOKEN=token,
        JPY_API_TOKEN=token,
        JUPYTERHUB_CLIENT_ID='jupyterhub-user-' + cognito_username,
        JUPYTERHUB_HOST='',
        JUPYTERHUB_OAUTH_CALLBACK_URL='/user/' + cognito_username + '/oauth_callback',
        JUPYTERHUB_USER=cognito_username,
        JUPYTERHUB_SERVER_NAME='',
        JUPYTERHUB_API_URL='https://jupyterhub.' + service + ':444/hub/api',
        JUPYTERHUB_ACTIVITY_URL='https://jupyterhub.' + service + ':444/hub/api/users/' + cognito_username + '/activity',
        JUPYTERHUB_ACTIVITY_INTERVAL='60',
        JUPYTERHUB_BASE_URL='/',
        JUPYTERHUB_SERVICE_PREFIX='/user/' + cognito_username + '/'))
