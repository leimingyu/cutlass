#!/usr/bin/env bash
# build.sh — Rebuild all SM 11.0 examples in build_sm110/
# GPU target : NVIDIA Thor (SM 11.0a)
# CUDA       : 13.1+
# Usage      : bash build.sh [example_name]
#              With no argument, builds all 6 examples.
#              Pass a name to build only that example, e.g.:
#                bash build.sh 48
#                bash build.sh 70
#                bash build.sh 73
#                bash build.sh 93
#                bash build.sh 03
#                bash build.sh 04

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUTLASS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$SCRIPT_DIR"

# ── Shared compiler flags ────────────────────────────────────────────────────
NVCC_FLAGS=(
  -std=c++17
  -O3
  --generate-code=arch=compute_110a,code=[sm_110a,compute_110a]
  --expt-relaxed-constexpr
  -ftemplate-backtrace-limit=0
  -lineinfo
  -DCUTLASS_ENABLE_TENSOR_CORE_MMA=1
  -DCUTLASS_ENABLE_GDC_FOR_SM100=1
)

# ── Shared include paths ─────────────────────────────────────────────────────
INCLUDES=(
  -I"$CUTLASS_DIR/include"
  -I"$CUTLASS_DIR/tools/util/include"
  -I"$CUTLASS_DIR/examples/common"
)

# ── Helper ───────────────────────────────────────────────────────────────────
build() {
  local label="$1"; shift
  echo "=== Building $label ==="
  nvcc "${NVCC_FLAGS[@]}" "${INCLUDES[@]}" "$@"
  echo "    OK"
}

# ── Per-example build functions ──────────────────────────────────────────────
build_48() {
  local out="$BUILD_DIR/examples/48_hopper_warp_specialized_gemm/48_hopper_warp_specialized_gemm"
  mkdir -p "$(dirname "$out")"
  build "48_hopper_warp_specialized_gemm" \
    -I"$CUTLASS_DIR/examples/48_hopper_warp_specialized_gemm" \
    "$CUTLASS_DIR/examples/48_hopper_warp_specialized_gemm/48_hopper_warp_specialized_gemm.cu" \
    -o "$out" -lcuda
}

build_70() {
  local out="$BUILD_DIR/examples/70_blackwell_gemm/70_blackwell_fp16_gemm"
  mkdir -p "$(dirname "$out")"
  build "70_blackwell_fp16_gemm" \
    -I"$CUTLASS_DIR/examples/70_blackwell_gemm" \
    "$CUTLASS_DIR/examples/70_blackwell_gemm/70_blackwell_fp16_gemm.cu" \
    -o "$out" -lcuda
}

build_73() {
  local out="$BUILD_DIR/examples/73_blackwell_gemm_preferred_cluster/73_blackwell_gemm_preferred_cluster"
  mkdir -p "$(dirname "$out")"
  build "73_blackwell_gemm_preferred_cluster" \
    -I"$CUTLASS_DIR/examples/73_blackwell_gemm_preferred_cluster" \
    "$CUTLASS_DIR/examples/73_blackwell_gemm_preferred_cluster/blackwell_gemm_preferred_cluster.cu" \
    -o "$out" -lcuda
}

build_93() {
  local out="$BUILD_DIR/examples/93_blackwell_low_latency_gqa/93_blackwell_low_latency_gqa"
  mkdir -p "$(dirname "$out")"
  build "93_blackwell_low_latency_gqa" \
    -I"$CUTLASS_DIR/examples/93_blackwell_low_latency_gqa" \
    "$CUTLASS_DIR/examples/93_blackwell_low_latency_gqa/tgv_gqa.cu" \
    -o "$out" -lcuda
}

build_03() {
  local tdir="$CUTLASS_DIR/examples/cute/tutorial/blackwell"
  local out="$BUILD_DIR/examples/cute/tutorial/blackwell/03_mma_tma_multicast_sm100"
  mkdir -p "$(dirname "$out")"
  build "03_mma_tma_multicast_sm100" \
    -I"$tdir" \
    "$tdir/03_mma_tma_multicast_sm100.cu" \
    -o "$out" -lcuda
}

build_04() {
  local tdir="$CUTLASS_DIR/examples/cute/tutorial/blackwell"
  local out="$BUILD_DIR/examples/cute/tutorial/blackwell/04_mma_tma_2sm_sm100"
  mkdir -p "$(dirname "$out")"
  build "04_mma_tma_2sm_sm100" \
    -I"$tdir" \
    "$tdir/04_mma_tma_2sm_sm100.cu" \
    -o "$out" -lcuda
}

# ── Dispatch ─────────────────────────────────────────────────────────────────
TARGET="${1:-all}"

case "$TARGET" in
  48)  build_48 ;;
  70)  build_70 ;;
  73)  build_73 ;;
  93)  build_93 ;;
  03)  build_03 ;;
  04)  build_04 ;;
  all)
    build_48
    build_70
    build_73
    build_93
    build_03
    build_04
    echo ""
    echo "=== All examples built successfully ==="
    ;;
  *)
    echo "Unknown target: $TARGET"
    echo "Valid targets: 48 70 73 93 03 04 all"
    exit 1
    ;;
esac
