%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add, uint256_eq
from starkware.starknet.common.syscalls import get_contract_address

from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.token.erc20.library import ERC20

#
# Storage
#

@storage_var
func cToken_underlying_asset() -> (res : felt):
end

@storage_var
func cToken_pool() -> (res : felt):
end

@storage_var
func cToken_total_supply() -> (res : Uint256):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    underlying_asset : felt
):
    ERC20.initializer(109214297711982, 1666468686, 18)
    cToken_underlying_asset.write(underlying_asset)
    return ()
end

#
# Getters
#

@view
func UNDERLYING_ASSET_ADDRESS{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (res : felt):
    let (res) = cToken_underlying_asset.read()
    return (res)
end

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC20.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end