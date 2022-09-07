%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc20.IERC20 import IERC20

from contracts.interfaces.i_4626 import I4626

const PRANK_USER_1 = 111
const PRANK_USER_2 = 222
const NAME = 109214297711982 # "cToken"
const SYMBOL = 1666468686 # "cTKN"
const DECIMALS = 18
const INITIAL_SUPPLY_LOW = 1000
const INITIAL_SUPPLY_HIGH = 0
const MAX_DEPOSIT_LOW = 100
const MAX_DEPOSIT_HIGH = 0
const MAX_MINT_LOW = 100
const MAX_MINT_HIGH = 0
const MAX_WITHDRAW_LOW = 100
const MAX_WITHDRAW_HIGH = 0
const MAX_REDEEM_LOW = 100
const MAX_REDEEM_HIGH = 0

@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        context.token = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo", [ids.NAME, ids.SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.PRANK_USER_1]).contract_address
        context.c_token = deploy_contract("./contracts/protocol/eip-4626.cairo", [context.token, ids.MAX_DEPOSIT_LOW, ids.MAX_DEPOSIT_HIGH, ids.MAX_MINT_LOW, ids.MAX_MINT_HIGH, ids.MAX_WITHDRAW_LOW, ids.MAX_WITHDRAW_HIGH, ids.MAX_REDEEM_LOW, ids.MAX_REDEEM_HIGH]).contract_address
    %}
    return ()
end

func get_contract_addresses() -> (
    token_address : felt, a_token_address : felt
):
    tempvar token
    tempvar c_token
    %{ ids.token = context.token %}
    %{ ids.c_token = context.c_token %}
    return (token, c_token)
end

@view
func test_constructor{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (local token, local c_token) = get_contract_addresses()

    let (asset_after) = I4626.asset(c_token)
    assert asset_after = token

    let (name_set) = I4626.name(c_token)
    assert name_set = NAME

    let (symbol_set) = I4626.symbol(c_token)
    assert symbol_set = SYMBOL

    let (asset_set) = I4626.asset(c_token)
    assert asset_set = token

    let (total_assets_set) = I4626.totalAssets(c_token)
    assert total_assets_set = Uint256(0,0)

    return ()
end

@view
func test_convertToShares{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let rand_uint = Uint256(100,0)
   let (equivalent_value) = I4626.convertToShares(c_token, rand_uint)
   assert equivalent_value = Uint256(100,0)

   return ()
end

@view
func test_convertToAssets{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let rand_uint = Uint256(100,0)
   let (equivalent_value) = I4626.convertToAssets(c_token, rand_uint)
   assert equivalent_value = Uint256(0,0)

   return ()
end

@view
func test_maxDeposit{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let (equivalent_value) = I4626.maxDeposit(c_token)
   assert equivalent_value = Uint256(100,0)

   return ()
end

@view
func test_maxMint{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let (equivalent_value) = I4626.maxMint(c_token)
   assert equivalent_value = Uint256(100,0)

   return ()
end

@view
func test_maxWithdraw{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let (equivalent_value) = I4626.maxWithdraw(c_token)
   assert equivalent_value = Uint256(100,0)

   return ()
end

@view
func test_maxRedeem{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let (equivalent_value) = I4626.maxRedeem(c_token)
   assert equivalent_value = Uint256(100,0)

   return ()
end

@view
func test_deposit{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let rand_uint = Uint256(100,0)

   %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.token) %}
       IERC20.approve(token, c_token, rand_uint)
   %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.c_token) %}
       let (shares_minted) = I4626.deposit(c_token, rand_uint, PRANK_USER_1)
   %{ stop_prank_callable() %}

   assert shares_minted = Uint256(100,0)
   let (balance) = I4626.balanceOf(c_token, PRANK_USER_1)
   assert balance = Uint256(100,0)

   return ()
end

@view
func test_mint{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let rand_uint = Uint256(100,0)

   %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.token) %}
       IERC20.approve(token, c_token, rand_uint)
   %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.c_token) %}
       let (shares_minted) = I4626.mint(c_token, rand_uint, PRANK_USER_1)
   %{ stop_prank_callable() %}

   assert shares_minted = Uint256(100,0)
   let (balance) = I4626.balanceOf(c_token, PRANK_USER_1)
   assert balance = Uint256(100,0)

   return ()
end


@external
func test_withdraw{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let rand_uint = Uint256(100,0)
   let rand_uint_2 = Uint256(50,0)

   test_mint()

   %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.c_token) %}
       let (returned_amount) = I4626.withdraw(c_token, rand_uint_2, PRANK_USER_1, PRANK_USER_1)
   %{ stop_prank_callable() %}

   assert returned_amount = Uint256(50,0)
   let (balance) = I4626.balanceOf(c_token, PRANK_USER_1)
   assert balance = Uint256(50,0)

   return ()
end


@external
func test_redeem{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
   alloc_locals
     
   let (local token, local c_token) = get_contract_addresses()
   let rand_uint = Uint256(100,0)
   let rand_uint_2 = Uint256(50,0)

   test_mint()

   %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.c_token) %}
       let (returned_amount) = I4626.redeem(c_token, rand_uint_2, PRANK_USER_1, PRANK_USER_1)
   %{ stop_prank_callable() %}

   assert returned_amount = Uint256(50,0)
   let (balance) = I4626.balanceOf(c_token, PRANK_USER_1)
   assert balance = Uint256(50,0)

   return ()
end