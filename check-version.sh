#!/bin/bash

SELF_DIR="$(dirname "$(realpath "${0}")")"
VERSION="${SELF_DIR}/version.md"

zlib_tag="1.3.1"
zstd_tag="1.5.6"
gmp_tag="6.3.0"
isl_tag="0.27"
mpfr_tag="4.2.1"
mpc_tag="1.3.1"
binutils_tag="2.44"
gcc_tag="14.2.0"

retry() {
  local n=0
  local max=5
  local delay=2
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Retrying in $delay seconds..."
        sleep $delay
      else
        echo "Command failed after $max attempts."
        return 1
      fi
    }
  done
}

version_gt() {
  local program_name="$1"
  local v1="$2"
  local v2="$3"
  #echo "正在比较版本 $program_name: $v1 和 $v2"
  if [[ $v1 == $v2 ]]; then
    return 1 # Not greater
  fi
  local IFS=.
  set -- $v1 $v2
  for i in "$@"; do
    v1_part=${1}
    v2_part=${2}
    shift
    shift
    if [[ -z "$v2_part" ]]; then
      return 0 # v1 has more parts and is considered newer
    fi
    if [[ "$v1_part" -gt "$v2_part" ]]; then
      return 0 # v1 is greater
    elif [[ "$v1_part" -lt "$v2_part" ]]; then
      return 1 # v2 is greater
    fi
    if [[ -z "$1" ]]; then
      if [[ -z "$v2_part" ]]; then
        return 1 # Versions are equal (shouldn't reach here due to initial check)
      else
        return 1 # v2 is considered newer
      fi
    fi
  done
  return 1 # v2 is greater or equal if loop completes
}

update_found=false # 初始化标志变量

# 获取 zlib 最新版本
zlib_tag1=$(retry curl -s https://api.github.com/repos/madler/zlib/releases/latest | jq -r '.tag_name' | sed 's/^v//')
zlib_latest_url=$(retry curl -s "https://api.github.com/repos/madler/zlib/releases/latest" | jq -r '.assets[] | select(.name | test("\\.tar\\.gz$")) | .browser_download_url' | head -n 1)
if version_gt "zlib" "$zlib_tag1" "$zlib_tag"; then
  echo "zlib有最新版：$zlib_tag1 最新地址是：$zlib_latest_url\n- zlib有最新版：${zlib_tag1} 最新地址是：${zlib_latest_url}" | tee -a "${VERSION}"
  update_found=true
else
  echo "zlib ${zlib_tag} 已经是最新版本，下载地址是 https://github.com/madler/zlib/releases/download/v${zlib_tag}/zlib-${zlib_tag}.tar.xz" | tee -a "${VERSION}"
fi

# 获取 zstd 最新版本
zstd_tag1=$(retry curl -s https://api.github.com/repos/facebook/zstd/releases/latest | jq -r '.tag_name' | sed 's/^v//')
zstd_latest_url=$(retry curl -s "https://api.github.com/repos/facebook/zstd/releases/latest" | jq -r '.assets[] | select(.name | test("\\.tar\\.gz$")) | .browser_download_url' | head -n 1)
if version_gt "zstd" "$zstd_tag1" "$zstd_tag"; then
  echo "zstd有最新版：$zstd_tag1 最新地址是：$zstd_latest_url\n- zstd有最新版：${zstd_tag1} 最新地址是：${zstd_latest_url}" | tee -a "${VERSION}"
  update_found=true
else
  echo "zstd ${zstd_tag} 已经是最新版本，下载地址是 https://github.com/facebook/zstd/releases/download/v${zstd_tag}/zstd-${zstd_tag}.tar.gz" | tee -a "${VERSION}"
fi

# 获取 gmp 最新版本
gmp_tag1="$(retry curl -s https://ftp.gnu.org/gnu/gmp/ | grep -oE 'href="gmp-([0-9.]+)\.tar\.(xz|gz)"' | sort -rV | head -n 1 | sed -r 's/href="gmp-(.+)\.tar\.(xz|gz)"/\1/')"
if version_gt "gmp" "$gmp_tag1" "$gmp_tag"; then
  echo "gmp有最新版：$gmp_tag1 ，下载地址是https://ftp.gnu.org/gnu/gmp/gmp-${gmp_tag1}.tar.xz\n- gmp有最新版：${gmp_tag1} ，下载地址是https://ftp.gnu.org/gnu/gmp/gmp-${gmp_tag1}.tar.xz" | tee -a "${VERSION}"
  update_found=true
else
  echo "gmp ${gmp_tag} 已经是最新版本，下载地址是 https://ftp.gnu.org/gnu/gmp/gmp-${gmp_tag}.tar.xz" | tee -a "${VERSION}"
fi

# 获取 isl 最新版本
isl_tag1="$(retry curl -s https://libisl.sourceforge.io/ | grep -oE 'href="isl-([0-9.]+)\.tar\.xz"' | sort -rV | head -n 1 | sed -r 's/href="isl-(.+)\.tar\.xz"/\1/')"
if version_gt "isl" "$isl_tag1" "$isl_tag"; then
  echo "isl有最新版：$isl_tag1 最新地址是：https://libisl.sourceforge.io/isl-${isl_tag1}.tar.xz\n- isl有最新版：${isl_tag1} 最新地址是：https://libisl.sourceforge.io/isl-${isl_tag1}.tar.xz" | tee -a "${VERSION}"
  update_found=true
else
  echo "isl ${isl_tag} 已经是最新版本，下载地址是 https://libisl.sourceforge.io/isl-${isl_tag}.tar.xz" | tee -a "${VERSION}"
fi

# 获取 MPFR 最新版本
mpfr_tag1="$(retry curl -s https://ftp.gnu.org/gnu/mpfr/ | grep -oE 'href="mpfr-([0-9.]+)\.tar\.(xz|gz)"' | sort -rV | head -n 1 | sed -r 's/href="mpfr-(.+)\.tar\.(xz|gz)"/\1/')"
if version_gt "mpfr" "$mpfr_tag1" "$mpfr_tag"; then
  echo "MPFR 最新版本是 $mpfr_tag1，下载地址是 https://ftp.gnu.org/gnu/mpfr/mpfr-${mpfr_tag1}.tar.xz\n- MPFR 最新版本是 ${mpfr_tag1}，下载地址是 https://ftp.gnu.org/gnu/mpfr/mpfr-${mpfr_tag1}.tar.xz" | tee -a "${VERSION}"
  update_found=true
else
  echo "MPFR ${mpfr_tag} 已经是最新版本，下载地址是 https://www.mpfr.org/mpfr-${mpfr_tag}/mpfr-${mpfr_tag}.tar.xz" | tee -a "${VERSION}"
fi

# 获取 MPC 最新版本
mpc_tag1="$(retry curl -s https://ftp.gnu.org/gnu/mpc/ | grep -oE 'href="mpc-([0-9.]+)\.tar\.(gz|xz)"' | sort -rV | head -n 1 | sed -r 's/href="mpc-(.+)\.tar\.(gz|xz)"/\1/')"
if version_gt "mpc" "$mpc_tag1" "$mpc_tag"; then
  echo "MPC 最新版本是 $mpc_tag1，下载地址是 https://ftp.gnu.org/gnu/mpc/mpc-${mpc_tag1}.tar.gz\n- MPC 最新版本是 ${mpc_tag1}，下载地址是 https://ftp.gnu.org/gnu/mpc/mpc-${mpc_tag1}.tar.gz" | tee -a "${VERSION}"
  update_found=true
else
  echo "MPC ${mpc_tag} 已经是最新版本，下载地址是 https://www.multiprecision.org/downloads/mpc-${mpc_tag}.tar.gz" | tee -a "${VERSION}"
fi

# 获取 Binutils 最新版本
binutils_tag1="$(retry curl -s https://ftp.gnu.org/gnu/binutils/ | grep -oE 'href="binutils-([0-9.]+)\.tar\.(xz|gz)"' | sort -rV | head -n 1 | sed -r 's/href="binutils-(.+)\.tar\.(xz|gz)"/\1/')"
if version_gt "binutils" "$binutils_tag1" "$binutils_tag"; then
  echo "Binutils 最新版本是 $binutils_tag1，下载地址是 https://ftp.gnu.org/gnu/binutils/binutils-${binutils_tag1}.tar.xz\n- Binutils 最新版本是 ${binutils_tag1}，下载地址是 https://ftp.gnu.org/gnu/binutils/binutils-${binutils_tag1}.tar.xz" | tee -a "${VERSION}"
  update_found=true
else
  echo "Binutils ${binutils_tag} 已经是最新版本，下载地址是 https://ftp.gnu.org/gnu/binutils/binutils-${binutils_tag}.tar.xz" | tee -a "${VERSION}"
fi

# 获取 GCC 最新版本
gcc_tag1="$(retry curl -s https://ftp.gnu.org/gnu/gcc/ | grep -oE 'href="gcc-([0-9.]+)/"' | sort -rV | head -n 1 | sed -r 's/href="gcc-(.+)\/"/\1/')"
if version_gt "gcc" "$gcc_tag1" "$gcc_tag"; then
  echo "GCC 最新版本是 $gcc_tag1，下载地址是 https://ftp.gnu.org/gnu/gcc/gcc-${gcc_tag1}/gcc-${gcc_tag1}.tar.xz\n- GCC 最新版本是 ${gcc_tag1}，下载地址是 https://ftp.gnu.org/gnu/gcc/gcc-${gcc_tag1}/gcc-${gcc_tag1}.tar.xz" | tee -a "${VERSION}"
  update_found=true
else
  echo "GCC ${gcc_tag} 已经是最新版本，下载地址是 https://ftp.gnu.org/gnu/gcc/gcc-${gcc_tag}/gcc-${gcc_tag}.tar.xz" | tee -a "${VERSION}"
fi

if [[ "$update_found" == "false" ]]; then
  echo "----------所有程序都没有更新的版本----------" | tee -a "${VERSION}"
fi
