#
# Dockerfile for building image for icarusalg
#
FROM sfbaylaser/slf7-essentials:latest
#FROM slf7-essentials:latest
LABEL Maintainer: Tracy Usher

#RUN git --version

# Set the versions for code
ENV larsoftobj_version='v09_29_00'
ENV icarusalg_version='v09_71_00'
ENV sbnobj_version='v09_16_00'

# Start by getting the underlying code required by icarusalg
# Essentially, this is included with LArSoftObj
RUN mkdir larsoft && \
  cd larsoft && \
  wget http://scisoft.fnal.gov/scisoft/bundles/tools/pullProducts && \
  chmod +x pullProducts && \
  mkdir products && \
  ./pullProducts products/ slf7 larsoftobj-${larsoftobj_version} prof && \
  ./pullProducts products/ slf7 larsoftobj-${larsoftobj_version} prof && \
  rm *tar.bz2

# Install PyQt5 and PyQtGraph
# NOTE: replacing the line python -m pip install PyQt5==5.11.3 pyqtgraph==0.11.0 
RUN cd / && \
  source larsoft/products/setup && \
  setup larsoftobj ${larsoftobj_version} -q e20:prof && \
  pip install --upgrade pip && \
  python -m pip install PyQt5 pyqtgraph && \
  pip install uproot awkward pandas matplotlib \
              plotly jupyterlab scipy pywavelets

# We need to get and build larcv
RUN cd / && \
  git clone https://github.com/DeepLearnPhysics/larcv2 && \
  cd larcv2 && \
  ls -la && \
  /bin/bash -c 'source ../larsoft/products/setup && \
                setup larsoftobj ${larsoftobj_version}-q e20:prof && \
                source configure.sh && \
                make'

# Install icarusalg
RUN cd / && \
  source larsoft/products/setup && \
  setup mrb && \
  export MRB_PROJECT=icarusalg && \
  mkdir icarusalg && \
  cd icarusalg && \
  mrb newDev -v ${icarusalg_version} -q e20:prof && \
  source localProducts_*/setup && \
  cd srcs/ && \
  mrb g --tag ${icarusalg_version} icarusalg && \
  mrb g --tag ${sbnobj_version} sbnobj && \
  cd ../build* && \
  mrbsetenv && \
  mrb i

