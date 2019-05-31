FROM nvidia/cuda:10.0-base
LABEL maintainer="shinn1r0 <github@shinichironaito.com>"

ARG python_version="3.7.3"
ARG nodejs_version="12"
ARG cica_version="v4.1.2"

EXPOSE 8888
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
ENV PATH $PYENV_ROOT/shims:$PATH

RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y

RUN apt-get install -y git
RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc && eval "$(pyenv init -)"

RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

RUN pyenv install ${python_version} && pyenv global ${python_version}
RUN pip install -U pip setuptools pipenv
RUN pip install -U ipython ipyparallel
RUN pip install -U jupyter jupyter-contrib-nbextensions jupyter-nbextensions-configurator jupyterthemes
RUN pip install -U jupyter_http_over_ws && jupyter serverextension enable --py jupyter_http_over_ws
RUN pip install -U isort autopep8
RUN pip install -U numpy pandas matplotlib
RUN pip install -U jupyterlab
RUN pip install -U ipywidgets ipympl nbdime
RUN pip install -U jupyterlab_code_formatter jupyterlab-git jupyterlab_templates jupyterlab_code_formatter jupyterlab_latex

RUN curl -sL https://deb.nodesource.com/setup_${nodejs_version}.x | bash -
RUN apt-get install -y nodejs

RUN apt-get install curl unzip -y
RUN mkdir -p /usr/share/fonts/opentype/noto
RUN curl -O https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
RUN unzip NotoSansCJKjp-hinted.zip -d /usr/share/fonts/opentype/noto
RUN rm NotoSansCJKjp-hinted.zip
RUN mkdir -p /usr/share/fonts/opentype/cica
RUN curl -LO https://github.com/miiton/Cica/releases/download/${cica_version}/Cica_${cica_version}.zip
RUN unzip Cica_${cica_version}.zip -d /usr/share/fonts/opentype/cica
RUN rm Cica_${cica_version}.zip
RUN apt-get install fontconfig
RUN fc-cache -f

RUN echo "\nfont.family: Noto Sans CJK JP" >> $(python -c 'import matplotlib as m; print(m.matplotlib_fname())') \
  && rm -f ~/.cache/matplotlib/font*
RUN ipython profile create
RUN jupyter contrib nbextension install --user
RUN jupyter nbextensions_configurator enable --user
RUN mkdir -p $(jupyter --data-dir)/nbextensions
RUN git clone https://github.com/lambdalisue/jupyter-vim-binding $(jupyter --data-dir)/nbextensions/vim_binding
RUN jupyter nbextension enable vim_binding/vim_binding
RUN jt -t onedork -vim -T -N -ofs 11 -f hack -tfs 11 -cellw 95%

COPY .jupyter ${HOME}/.jupyter
RUN cat ${HOME}/.ipython/profile_default/ipython_config.py | sed -e "s/#c.InteractiveShellApp.exec_lines = \[\]/c.InteractiveShellApp.exec_lines = \['%matplotlib widget'\]/g" | tee ${HOME}/.ipython/profile_default/ipython_config.py

RUN ipcluster nbextension enable
RUN jupyter nbextension enable toggle_all_line_numbers/main
RUN jupyter nbextension enable code_prettify/code_prettify
RUN jupyter nbextension enable code_prettify/isort
RUN jupyter nbextension enable code_prettify/autopep8
RUN jupyter nbextension enable livemdpreview/livemdpreview
RUN jupyter nbextension enable codefolding/main
RUN jupyter nbextension enable execute_time/ExecuteTime
RUN jupyter nbextension disable hinterland/hinterland
RUN jupyter nbextension enable toc2/main
RUN jupyter nbextension enable varInspector/main
RUN jupyter nbextension enable ruler/main
RUN jupyter nbextension enable latex_envs/latex_envs
RUN jupyter nbextension enable comment-uncomment/main
RUN jupyter nbextension enable scratchpad/main
RUN jupyter nbextension enable gist_it/main
RUN jupyter nbextension enable keyboard_shortcut_editor/main
RUN jupyter nbextension enable hide_input/main
RUN jupyter nbextension enable hide_input_all/main
RUN jupyter nbextension enable table_beautifier/main
RUN jupyter nbextension enable equation-numbering/main
RUN jupyter nbextension enable highlight_selected_word/main
RUN jupyter nbextension enable freeze/main
RUN jupyter nbextension enable snippets/main
RUN jupyter nbextension enable snippets_menu/main
RUN jupyter nbextension enable vim_binding/vim_binding

RUN jupyter labextension install jupyterlab_vim
RUN jupyter labextension install @lckr/jupyterlab_variableinspector
RUN jupyter labextension install @jupyterlab/toc
RUN jupyter labextension install @ryantam626/jupyterlab_code_formatter
RUN jupyter labextension install jupyterlab_tensorboard
RUN jupyter labextension install @jupyterlab/git
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
RUN jupyter labextension install jupyterlab_voyager
RUN jupyter labextension install @krassowski/jupyterlab_go_to_definition
RUN jupyter labextension install jupyterlab_templates
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install jupyter-matplotlib
RUN jupyter labextension install @ryantam626/jupyterlab_code_formatter
RUN jupyter labextension install @jupyterlab/katex-extension
RUN jupyter labextension install @jupyterlab/latex
RUN jupyter labextension install jupyterlab-drawio

RUN jupyter serverextension enable --py jupyterlab_code_formatter
RUN jupyter serverextension enable --py jupyterlab_git
RUN jupyter serverextension enable --py jupyterlab_templates
RUN jupyter serverextension enable --py jupyterlab_code_formatter
RUN jupyter serverextension enable --py nbdime --sys-prefix
