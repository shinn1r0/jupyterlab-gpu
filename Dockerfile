ARG cuda_version="10.0"
FROM nvidia/cuda:${cuda_version}-base
LABEL maintainer="shinn1r0 <github@shinichironaito.com>"

ARG python_version="3.7.3"
ARG nodejs_version="12"
ARG cica_version="v5.0.1"

EXPOSE 8888
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HOME /root
ENV PATH $HOME/miniconda/bin:$PATH

RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends curl ca-certificates && \
  curl -sL https://deb.nodesource.com/setup_${nodejs_version}.x | bash - && \
  apt-get install -y --no-install-recommends git fontconfig unzip nodejs && \
  curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh && \
  bash ~/miniconda.sh -b -p $HOME/miniconda && \
  export PATH="$HOME/miniconda/bin:$PATH" && \
  . $HOME/miniconda/bin/activate && \
  echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc && \
  mkdir -p /usr/share/fonts/opentype/noto && \
  curl -O https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip && \
  unzip NotoSansCJKjp-hinted.zip -d /usr/share/fonts/opentype/noto && \
  rm NotoSansCJKjp-hinted.zip && \
  mkdir -p /usr/share/fonts/opentype/cica && \
  curl -LO https://github.com/miiton/Cica/releases/download/${cica_version}/Cica_${cica_version}_with_emoji.zip && \
  unzip Cica_${cica_version}.zip -d /usr/share/fonts/opentype/cica && \
  rm Cica_${cica_version}.zip && \
  fc-cache -f && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get purge -y curl unzip && \
  apt-get autoremove -y && apt-get autoclean -y

RUN conda config --append channels conda-forge && \
  conda config --add channels pytorch && \
  conda install -y python=${python_version} \
  numpy scipy numba pandas dask matplotlib numexpr \
  scikit-learn scikit-image bokeh pillow accimage pyspark xlrd sympy altair \
  ipython ipyparallel ipywidgets ipympl \
  jupyter jupyterlab nbdime nbconvert nbformat \
  beautifulsoup4 lxml jinja2 sphinx \
  isort pep8 autopep8 flake8 pyflakes pylint jedi tqdm \
  tensorboard pytorch torchvision cudatoolkit=${cuda_version} && \
  conda update --all -y && \
  conda clean --all && \
  pip install -U pip kaggle \
  jupyterlab_code_formatter jupyterlab-git jupyterlab_templates jupyterlab_latex jupyter-tensorboard && \
  rm -rf ${HOME}/.cache/pip

RUN echo "\nfont.family: Noto Sans CJK JP" >> $(python -c 'import matplotlib as m; print(m.matplotlib_fname())') \
  && rm -f ~/.cache/matplotlib/font* && \
  ipython profile create && \
  cat ${HOME}/.ipython/profile_default/ipython_config.py | sed -e "s/#c.InteractiveShellApp.exec_lines = \[\]/c.InteractiveShellApp.exec_lines = \['%matplotlib widget'\]/g" | tee ${HOME}/.ipython/profile_default/ipython_config.py

COPY .jupyter ${HOME}/.jupyter

RUN jupyter labextension install jupyterlab_vim && \
  jupyter labextension install @jupyterlab/git && \
  jupyter labextension install @lckr/jupyterlab_variableinspector && \
  jupyter labextension install @krassowski/jupyterlab_go_to_definition && \
  jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
  jupyter labextension install jupyter-matplotlib && \
  #jupyter labextension install jupyterlab_voyager && \
  jupyter labextension install @jupyterlab/toc && \
  jupyter labextension install @ryantam626/jupyterlab_code_formatter && \
  jupyter labextension install jupyterlab_tensorboard && \
  jupyter labextension install jupyterlab_templates && \
  jupyter labextension install @jupyterlab/latex && \
  jupyter labextension install @jupyterlab/katex-extension && \
  jupyter labextension install jupyterlab-drawio && \
  jupyter serverextension enable --py jupyterlab_git && \
  jupyter serverextension enable --py jupyterlab_code_formatter && \
  jupyter serverextension enable --py jupyterlab_templates && \
  nbdime extensions --enable
