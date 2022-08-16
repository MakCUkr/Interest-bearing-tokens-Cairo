%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add, uint256_eq
from starkware.starknet.common.syscalls import get_contract_address

from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.token.erc20.library import ERC20

from contracts.interfaces.i_pool import IPool
from contracts.libraries.math.wad_ray_math import ray_div, ray_mul
from contracts.libraries.types.data_types import DataTypes

#
# Storage
#

@storage_var
func AToken_underlying_asset() -> (res : felt):
end

@storage_var
func AToken_pool() -> (res : felt):
end

@storage_var
func AToken_total_supply() -> (res : Uint256):
end

@storage_var
func AToken_user_states(user : felt) -> (state : DataTypes.UserState):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    pool : felt,
    underlying_asset : felt,
    a_token_decimals : felt,
    a_token_name : felt,
    a_token_symbol : felt,
):
    ERC20.initializer(a_token_name, a_token_symbol, a_token_decimals)

    AToken_underlying_asset.write(underlying_asset)
    AToken_pool.write(pool)

    return ()
end

#
# Getters
#

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
func totalSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    totalSupply : Uint256
):
    let (totalSupply) = AToken_total_supply.read()
    return (totalSupply)
end

@view
func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    decimals : felt
):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (balance : Uint256):
    alloc_locals
    let (balance_scaled) = scaled_balance_of(account)
    let (pool) = POOL()
    let (underlying) = UNDERLYING_ASSET_ADDRESS()
    let (liquidity_index) = IPool.get_reserve_normalized_income(pool, underlying)
    let (balance) = ray_mul(balance_scaled, liquidity_index)
    return (balance)
end

@view
func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt
) -> (remaining : Uint256):
    let (remaining : Uint256) = ERC20.allowance(owner, spender)
    return (remaining)
end

@view
func UNDERLYING_ASSET_ADDRESS{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (res : felt):
    let (res) = AToken_underlying_asset.read()
    return (res)
end

@view
func POOL{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (res) = AToken_pool.read()
    return (res)
end

@view
func scaled_balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user : felt
) -> (balance : Uint256):
    let (state) = AToken_user_states.read(user)
    return (state.balance)
end

#
# Externals
#

@external
func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    recipient : felt, amount : Uint256
) -> (success : felt):
    ERC20.transfer(recipient, amount)
    return (TRUE)
end

@external
func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : Uint256
) -> (success : felt):
    ERC20.transfer_from(sender, recipient, amount)
    return (TRUE)
end

@external
func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> (success : felt):
    ERC20.approve(spender, amount)
    return (TRUE)
end

@external
func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, added_value : Uint256
) -> (success : felt):
    ERC20.increase_allowance(spender, added_value)
    return (TRUE)
end

@external
func decreaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, subtracted_value : Uint256
) -> (success : felt):
    ERC20.decrease_allowance(spender, subtracted_value)
    return (TRUE)
end

@external
func mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, on_behalf_of : felt, amount : Uint256, index : Uint256
) -> (success : felt):
    return _mint_scaled(caller, on_behalf_of, amount, index)
end

@external
func burn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_ : felt, receiver_or_underlying : felt, amount : Uint256, index : Uint256
) -> (success : felt):
    alloc_locals
    _burn_scaled(from_, receiver_or_underlying, amount, index)
    let (contract_address) = get_contract_address()
    if receiver_or_underlying != contract_address:
        transfer_underlying_to(receiver_or_underlying, amount)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end
    return (TRUE)
end

@external
func transfer_underlying_to{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    target : felt, amount : Uint256
):
    alloc_locals
    let (underlying) = UNDERLYING_ASSET_ADDRESS()
    IERC20.transfer(contract_address=underlying, recipient=target, amount=amount)
    return ()
end

#
# Internals
#

func get_user_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user : felt
) -> (index : Uint256):
    let (state) = AToken_user_states.read(user)
    return (state.additional_data)
end

func _mint_scaled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, on_behalf_of : felt, amount : Uint256, index : Uint256
) -> (success : felt):
    alloc_locals

    # function _mintScaled from ScaledBalanceTokenBase below
    let (amount_scaled) = ray_div(amount, index)

    let (scaled_balance) = scaled_balance_of(on_behalf_of)
    let (previous_user_state) = get_user_state(on_behalf_of)
    let (previous_index) = get_user_index(on_behalf_of)

    let (new_balance) = ray_mul(scaled_balance, index)
    let (old_balance) = ray_mul(scaled_balance, previous_index)
    let (balance_increase) = uint256_sub(new_balance, old_balance)

    with_attr error_message("Invalid mint amount"):
        let (is_zero) = uint256_eq(amount_scaled, Uint256(0, 0))
        assert is_zero = FALSE
    end

    set_user_state(on_behalf_of, DataTypes.UserState(previous_user_state.balance, index))

    # function _mint from MintableIncentivizedERC20 below

    let (old_user_state) = get_user_state(on_behalf_of)
    let (old_total_supply) = AToken_total_supply.read()
    let (new_total_supply, _) = uint256_add(old_total_supply, amount)

    AToken_total_supply.write(new_total_supply)

    let old_account_balance = old_user_state.balance
    let (new_account_balance, _) = uint256_add(old_account_balance, amount)
    let new_user_state = DataTypes.UserState(new_account_balance, old_user_state.additional_data)

    AToken_user_states.write(on_behalf_of, new_user_state)

    let (is_zero) = uint256_eq(scaled_balance, Uint256(0, 0))

    return (is_zero)
end

func _burn_scaled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user : felt, target : felt, amount : Uint256, index : Uint256
):
    alloc_locals

    # function _burnScaled from ScaledBalanceTokenBase below

    let (amount_scaled) = ray_div(amount, index)

    let (previous_user_state) = get_user_state(target)
    let (scaled_balance) = scaled_balance_of(target)
    let (previous_index) = get_user_index(target)

    let (new_balance) = ray_mul(scaled_balance, index)
    let (old_balance) = ray_mul(scaled_balance, previous_index)
    let (balance_increase) = uint256_sub(new_balance, old_balance)

    set_user_state(target, DataTypes.UserState(scaled_balance, index))

    # function _burn from MintableIncentivizedERC20 below

    let (old_user_state) = get_user_state(target)
    let (old_total_supply) = totalSupply()
    let (new_total_supply) = uint256_sub(old_total_supply, amount)

    AToken_total_supply.write(new_total_supply)

    let (old_account_balance) = scaled_balance_of(target)
    let (new_account_balance) = uint256_sub(old_account_balance, amount)

    set_user_state(target, DataTypes.UserState(new_account_balance, old_user_state.additional_data))

    return ()
end

func get_user_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user : felt
) -> (res : DataTypes.UserState):
    let (res) = AToken_user_states.read(user)
    return (res)
end

func set_user_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user : felt, state : DataTypes.UserState
):
    AToken_user_states.write(user, state)
    return ()
end
