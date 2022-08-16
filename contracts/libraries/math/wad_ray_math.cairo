from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_mul,
    uint256_unsigned_div_rem,
    uint256_le,
)

const UINT128_MAX = 2 ** 128 - 1

# WAD = 1 * 10 ^ 18
const WAD = 10 ** 18
const HALF_WAD = WAD / 2

# RAY = 1 * 10 ^ 27
const RAY = 10 ** 27
const HALF_RAY = RAY / 2

# WAD_RAY_RATIO = 1 * 10 ^ 9
const WAD_RAY_RATIO = 10 ** 9
const HALF_WAD_RAY_RATION = WAD_RAY_RATIO / 2

func ray() -> (ray : Uint256):
    return (Uint256(RAY, 0))
end

func wad() -> (wad : Uint256):
    return (Uint256(WAD, 0))
end

func half_ray() -> (half_ray : Uint256):
    return (Uint256(HALF_RAY, 0))
end

func half_wad() -> (half_wad : Uint256):
    return (Uint256(HALF_WAD, 0))
end

func wad_ray_ratio() -> (ratio : Uint256):
    return (Uint256(WAD_RAY_RATIO, 0))
end

func half_wad_ray_ratio() -> (ratio : Uint256):
    return (Uint256(HALF_WAD_RAY_RATION, 0))
end

func uint256_max() -> (max : Uint256):
    return (Uint256(UINT128_MAX, UINT128_MAX))
end

func ray_mul{range_check_ptr}(a : Uint256, b : Uint256) -> (res : Uint256):
    alloc_locals
    if a.high + a.low == 0:
        return (Uint256(0, 0))
    end
    if b.high + b.low == 0:
        return (Uint256(0, 0))
    end

    let (UINT256_MAX) = uint256_max()
    let (HALF_RAY_UINT) = half_ray()
    let (RAY_UINT) = ray()

    with_attr error_message("RAY div overflow"):
        let (bound) = uint256_sub(UINT256_MAX, HALF_RAY_UINT)
        let (quotient, rem) = uint256_unsigned_div_rem(bound, b)
        let (le) = uint256_le(a, quotient)
        assert le = 1
    end

    let (ab, _) = uint256_mul(a, b)
    let (abHR, _) = uint256_add(ab, HALF_RAY_UINT)
    let (res, _) = uint256_unsigned_div_rem(abHR, RAY_UINT)
    return (res)
end

func ray_div{range_check_ptr}(a : Uint256, b : Uint256) -> (res : Uint256):
    alloc_locals
    with_attr error_message("Divide by zero"):
        assert_not_zero(b.high + b.low)
    end

    let (halfB, _) = uint256_unsigned_div_rem(b, Uint256(2, 0))

    let (UINT256_MAX) = uint256_max()
    let (RAY_UINT) = ray()

    with_attr error_message("RAY multiplication overflow"):
        let (bound) = uint256_sub(UINT256_MAX, halfB)
        let (quo, _) = uint256_unsigned_div_rem(bound, RAY_UINT)
        let (le) = uint256_le(a, quo)
        assert le = 1
    end

    let (aRAY, _) = uint256_mul(a, RAY_UINT)
    let (aRAYHalfB, _) = uint256_add(aRAY, halfB)
    let (res, _) = uint256_unsigned_div_rem(aRAYHalfB, b)
    return (res)
end
