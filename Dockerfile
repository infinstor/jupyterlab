FROM pytorch/pytorch

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN groupadd -g 1000 ec2-user && \    
    groupadd -g 993 docker && \
    useradd -u 1000 -g ec2-user -m ec2-user -G docker && \   
    usermod -p "*" ec2-user

RUN apt update
RUN apt install git emacs vim sudo curl gnupg dirmngr unzip -y

RUN curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
RUN install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/
RUN echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | tee /etc/apt/sources.list.d/conda.list
RUN apt update
RUN apt install conda -y
RUN ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
RUN mkdir -p /opt/conda/envs
RUN /opt/conda/bin/python -m pip install ipython mlflow infinstor_mlflow_plugin infinstor

RUN /opt/conda/bin/python -m pip install wheel
RUN /opt/conda/bin/python -m pip install jupyterhub jupyterlab
RUN /opt/conda/bin/python -m pip install ipywidgets
RUN /opt/conda/bin/python -m pip install mlflow
RUN AIOHTTP_NO_EXTENSIONS=1 MULTIDICT_NO_EXTENSIONS=1 YARL_NO_EXTENSIONS=1 /opt/conda/bin/python -m pip install aiohttp
RUN /opt/conda/bin/python -m pip install infinstor
RUN /opt/conda/bin/python -m pip install infinstor-mlflow-plugin
RUN /opt/conda/bin/python -m pip install jupyterlab_infinstor


RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g @jupyterlab/notebook
RUN npm install -d jupyterlab-infinstor

RUN npm install -g configurable-http-proxy
RUN mkdir -p /opt/jupyterhub/etc/jupyterhub
RUN echo "c.Spawner.default_url = '/lab'" >> /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py
RUN mkdir -p /.jupyter
RUN rm -f /.jupyter/jupyter_server_config.py
RUN echo 'c.ServerApp.shutdown_no_activity_timeout = 10 * 60' >> /.jupyter/jupyter_server_config.py
RUN echo 'c.ServerApp.iopub_data_rate_limit = 0' >> /.jupyter/jupyter_server_config.py
RUN echo 'c.ServerApp.iopub_msg_rate_limit = 0' >> /.jupyter/jupyter_server_config.py
RUN echo 'c.MappingKernelManager.cull_idle_timeout = 30 * 60' >> /.jupyter/jupyter_server_config.py
RUN echo 'c.MappingKernelManager.cull_interval = 1 * 60' >> /.jupyter/jupyter_server_config.py
RUN echo 'c.MappingKernelManager.cull_connected = True' >> /.jupyter/jupyter_server_config.py

RUN /opt/conda/bin/jupyter labextension install jupyterlab-infinstor

EXPOSE 8888
