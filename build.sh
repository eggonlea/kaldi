# Set path to ndk-bundle
export NDK_BUNDLE_DIR=~/Android/Sdk/ndk-bundle/

# Export PATH to contain directories of clang and aarch64-linux-android-* utilities
export PATH=${NDK_BUNDLE_DIR}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/:${NDK_BUNDLE_DIR}/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# Setup LDFLAGS so that loader can find libgcc and pass -lm for sqrt
export LDFLAGS="-L${NDK_BUNDLE_DIR}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/lib/gcc/aarch64-linux-android/4.9.x -lm"

# Setup the clang cross compile options
#export CLANG_FLAGS="-target aarch64-linux-android --sysroot ${NDK_BUNDLE_DIR}/platforms/android-23/arch-arm64 -gcc-toolchain ${NDK_BUNDLE_DIR}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/"

# Dependency
cd tools
./extras/check_dependencies.sh
OPENFST_VERSION=1.6.9
wget -T 10 -t 1 http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-${OPENFST_VERSION}.tar.gz
tar xvzf openfst-${OPENFST_VERSION}.tar.gz
cd openfst-${OPENFST_VERSION}
sed -i -e 's/LDADD = libfstfarscript.la/LDADD = libfstfarscript.la libfstfar.la/g' src/extensions/far/Makefile.am
CXX=aarch64-linux-android28-clang++ CC=aarch64-linux-android28-clang ./configure --prefix=`pwd` --enable-static --enable-shared --enable-far --enable-ngram-fsts --host=aarch64-linux-android LIBS="-ldl"
make -j 4
make install
cd ..
ln -s openfst-${OPENFST_VERSION} openfst

# Configure for Android
cd src
AR=aarch64-linux-android-ar AS=aarch64-linux-android-as CXX=aarch64-linux-android28-clang++ RANLIB=aarch64-linux-android-ranlib CXXFLAGS=HAVE_EXECINFO_H ./configure --static --host=aarch64-linux-android --android-incdir=/home/li/Android/Sdk/ndk-bundle/sysroot/usr/include --mathlib=OPENBLAS --openblas-root=/home/li/vobs/OpenBLAS/out

# Compile
sed -i -e 's/-DHAVE_EXECINFO_H=0//g' -e 's/-lpthread//g' -e 's/-g # -O0 -DKALDI_PARANOID/-O3 -DNDEBUG/g' kaldi.mk
make clean -j
make depend -j
make -j 4
cd ..

