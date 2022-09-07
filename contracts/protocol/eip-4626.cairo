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

from contracts.protocol.c_pool import CPool


#
# Storage variables
#

@storage_var
func cToken_underlying_asset() -> (res : felt):
end

@storage_var
func max_deposit_val() -> (res : Uint256):
end

@storage_var
func max_mint_val() -> (res : Uint256):
end

@storage_var
func max_withdraw_val() -> (res : Uint256):
end

@storage_var
func max_redeem_val() -> (res : Uint256):
end

#
# ERC20 Getters
#

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt):
    let (res) = ERC20.name()
    return (res)
end 

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt):
    let (res) = ERC20.symbol()
    return (res)
end

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    totalSupply: Uint256
):
    let (res: Uint256) = ERC20.total_supply()
    return (res)
end

@view
func decimals{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    decimals: felt
) :
    let (res) = ERC20.decimals()
    return (res)
end

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    balance_ret: Uint256
):
    let (res: Uint256) = ERC20.balance_of(account)
    return (res)
end

@view
func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, spender: felt
) -> (allowance_ret: Uint256):
    let (res: Uint256) = ERC20.allowance(owner, spender)
    return (res)
end

#
# ERC20 Actions
#

@external
func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, amount: Uint256
) -> (success: felt) :
    ERC20.transfer(recipient, amount)
    return (TRUE)
end

@external
func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    sender: felt, recipient: felt, amount: Uint256
) -> (success: felt): 
    ERC20.transfer_from(sender, recipient, amount)
    return (TRUE)
end

@external
func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, amount: Uint256
) -> (success: felt) :
    ERC20.approve(spender, amount)
    return (TRUE)
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    underlying_asset : felt,
    max_deposit : Uint256,
    max_mint : Uint256,
    max_withdraw : Uint256,
    max_redeem : Uint256
):
    ERC20.initializer(109214297711982, 1666468686, 18)
    cToken_underlying_asset.write(underlying_asset)
    max_deposit_val.write(max_deposit)
    max_mint_val.write(max_mint)
    max_withdraw_val.write(max_withdraw)
    max_redeem_val.write(max_redeem)
    return ()
end

#
# Getters
#

@view
func asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (res : felt):
    let (res) = cToken_underlying_asset.read()
    return (res)
end

@view
func totalAssets{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (res : Uint256):
    let (contract_address) = get_contract_address()
    let(underlying_asset) = asset()
    let (res) = IERC20.balanceOf(underlying_asset, contract_address)
    return (res)
end

# @dev calculates the value of c_token_amount cTokens in underlying asset
@view
func convertToShares{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset_amt: Uint256
) -> (equiv_token_value : Uint256):
    alloc_locals
    let (total_asset_balance) = totalAssets()
    let (share_supply: Uint256) = totalSupply()
    let (mul_res, _) = uint256_mul(asset_amt, total_asset_balance)

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    let (equiv_share_value, _) = uint256_unsigned_div_rem(mul_res, share_supply)

    let (is_zero) = uint256_eq(equiv_share_value, Uint256(0,0))
    if is_zero == 1:
        return (asset_amt)
    else:
        return (equiv_share_value)
    end
end


#  @dev calculates the value of token_amount of underlying asset in cTokens
@view
func convertToAssets{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    share_amt: Uint256
) -> (equiv_asset_value : Uint256):
    alloc_locals
    let (total_asset_balance) = totalAssets()
    let (share_supply: Uint256) = totalSupply()

    let (mul_res, _) = uint256_mul(share_amt, share_supply)

    tempvar syscall_ptr = syscall_ptr
    tempvar pedersen_ptr = pedersen_ptr
    tempvar range_check_ptr = range_check_ptr

    let (asset_value, _) = uint256_unsigned_div_rem(mul_res, total_asset_balance)

    return (asset_value)
end

@view
func maxDeposit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : Uint256
):
    let (res: Uint256) = max_deposit_val.read()
    return (res)
end

@view
func maxMint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : Uint256
):
    let (res: Uint256) = max_mint_val.read()
    return (res)
end

@view
func maxWithdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : Uint256
):
    let (res: Uint256) = max_withdraw_val.read()
    return (res)
end

@view
func maxRedeem{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : Uint256
):
    let (res: Uint256) = max_redeem_val.read()
    return (res)
end

@view 
func previewDeposit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset_amt: Uint256
) -> (share_amt: Uint256):
    let (shares) = convertToShares(asset_amt)
    return (shares)
end

@view 
func previewMint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset_amt: Uint256
) -> (share_amt: Uint256):
    let (shares) = convertToShares(asset_amt)
    return (shares)
end

@view 
func previewWithdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    share_amt: Uint256
) -> (equiv_asset_value: Uint256):
    let (assets) = convertToAssets(share_amt)
    return (assets)
end

@view 
func previewRedeem{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    share_amt: Uint256
) -> (equiv_asset_value: Uint256):
    let (assets) = convertToAssets(share_amt)
    return (assets)
end

# Deposits and Withdrawals

@external
func deposit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    assets: Uint256,
    receiver: felt
) -> (shares : Uint256):
    alloc_locals

    let (caller) = get_caller_address()
    let (contract_address) = get_contract_address()

    let (shares_amt) = convertToShares(assets)
    let (underlying_addr) = asset()

    let (allowance) = IERC20.allowance(underlying_addr, caller, contract_address)

    IERC20.transferFrom(underlying_addr, caller, contract_address, assets)
    ERC20._mint(receiver, shares_amt)
    return (shares_amt)
end

@external
func mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    assets: Uint256,
    receiver: felt
) -> (shares : Uint256):
    let (shares_amt) = deposit(assets, receiver)
    return (shares_amt)
end

@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    assets: Uint256, 
    receiver: felt, 
    owner: felt
) -> (shares : Uint256):
    alloc_locals

    let (caller) = get_caller_address()
    assert caller = owner
    let (shares_amt) = convertToShares(assets)
    let (underlying_addr) = asset()
    
    IERC20.transfer(underlying_addr, receiver, assets)
    ERC20._burn(owner, shares_amt)
    
    return (shares_amt)
end

@external
func redeem{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    assets: Uint256, 
    receiver: felt, 
    owner: felt
) -> (shares : Uint256):
    let (shares_amt) = withdraw(assets, receiver, owner)
    return (shares_amt)
end