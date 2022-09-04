%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import (
    Uint256, 
    uint256_sub, 
    uint256_add, 
    uint256_eq, 
    uint256_mul, 
    uint256_unsigned_div_rem
)
from starkware.starknet.common.syscalls import get_contract_address
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.token.erc20.library import ERC20

from contracts.protocol.c_pool_ns import CPool
#
# Storage
#

@storage_var
func cToken_underlying_asset() -> (res : felt):
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

    CPool.set_token_balance(Uint256(1000000000, 0)) # 1e9
    CPool.set_cToken_balance(Uint256(1100000000, 0)) # 1.1e9

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

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account: felt
) -> (balance: Uint256):
    let (balance: Uint256) = ERC20.balance_of(account)
    return (balance)
end

# @dev calculates the value of c_token_amount cTokens in underlying asset
@view
func get_token_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    c_token_amount: Uint256
) -> (equiv_token_value : Uint256):
    alloc_locals

    let (total_token_balance) = CPool.get_token_balance()
    let (cToken_supply) = CPool.get_c_token_balance()

    let (mul_res, _) = uint256_mul(c_token_amount, total_token_balance)

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    let (res, _) = uint256_unsigned_div_rem(mul_res, cToken_supply)

    return (res)
end

# @dev calculates the value of token_amount of underlying asset in cTokens
@view
func get_c_token_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_amount: Uint256
) -> (equiv_c_token_value : Uint256):
    alloc_locals
    let (total_token_balance) = CPool.get_token_balance()
    let (cToken_supply) = CPool.get_c_token_balance()

    let (mul_res, _) = uint256_mul(token_amount, cToken_supply)

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    let (res, _) = uint256_unsigned_div_rem(mul_res, total_token_balance)

    return (res)
end

@external
func mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    to: felt,
    token_amount: Uint256
) -> (res : Uint256):
    alloc_locals

    let (caller) = get_caller_address()
    let (contract_address) = get_contract_address()
    let (cToken_amount) = get_c_token_value(token_amount)
    let (underlying_addr) = UNDERLYING_ASSET_ADDRESS()

    update_balances_on_mint(token_amount, cToken_amount)
    IERC20.transferFrom(underlying_addr, caller, contract_address, token_amount)
    ERC20._mint(to, cToken_amount)
    return (cToken_amount)
end

@external
func burn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    c_token_amount: Uint256
) -> (res : Uint256):
    alloc_locals

    let (token_amount) = get_token_value(c_token_amount)
    let (caller) = get_caller_address()
    let (underlying_addr) = UNDERLYING_ASSET_ADDRESS()
    
    update_balances_on_burn(token_amount, c_token_amount)
    IERC20.transfer(underlying_addr, caller, token_amount)
    ERC20._burn(caller, c_token_amount)
    
    return (token_amount)
end

#
# Internal functions
#
func update_balances_on_mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_amount: Uint256,
    cToken_amount: Uint256
):
    alloc_locals

    let (total_token_balance) = CPool.get_token_balance()
    let (cToken_supply) = CPool.get_c_token_balance()

    let (new_total_token_balance, _) = uint256_add(total_token_balance, token_amount)
    let (new_cToken_supply, _) = uint256_add(cToken_supply, cToken_amount)

    CPool.set_token_balance(new_total_token_balance)
    CPool.set_cToken_balance(new_cToken_supply)
    return ()
end

func update_balances_on_burn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_amount: Uint256,
    cToken_amount: Uint256
): 
    alloc_locals

    let (total_token_balance) = CPool.get_token_balance()
    let (cToken_supply) = CPool.get_c_token_balance()

    let (new_total_token_balance) = uint256_sub(total_token_balance, token_amount)
    let (new_cToken_supply) = uint256_sub(cToken_supply, cToken_amount)

    CPool.set_token_balance(new_total_token_balance)
    CPool.set_cToken_balance(new_cToken_supply)
    return ()
end