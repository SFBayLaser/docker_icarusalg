#
# Dockerfile for building image for icarusalg
#
FROM sfbaylaser/slf7-essentials:latest
LABEL Maintainer: Tracy Usher

# Start by getting the underlying code required by icarusalg
# Essentially, this is included with LArSoftObj
RUN mkdir larsoft && \
  cd larsoft && \
  wget http://scisoft.fnal.gov/scisoft/bundles/tools/pullProducts && \
  chmod +x pullProducts && \
  mkdir products && \
  ./pullProducts products/ slf7 larsoftobj-v09_05_00 e19 prof && \
  ./pullProducts products/ slf7 larsoftobj-v09_05_00 e19 prof && \
  rm *tar.bz2

# Install PyQt5 and PyQtGraph
RUN cd / && \
  source larsoft/products/setup && \
  setup larsoftobj v09_05_00 -q e19:prof && \
  pip install --upgrade pip && \
  pip install pyqt5==5.11.3 pyqtgraph \
              uproot awkward pandas \
              plotly jupyterlab

# Install icarusalg
RUN cd / && \
  source larsoft/products/setup && \
  setup mrb && \
  export MRB_PROJECT=icarusalg && \
  mkdir icarusalg && \
  cd icarusalg && \
  mrb newDev -v v09_16_00 -q e19:prof && \
  source localProducts_*/setup && \
  cd srcs/ && \
  mrb g icarusalg && \
  cd icarusalg && \
  git checkout develop && \
  cd ../../build* && \
  mrbsetenv && \
  mrb i


