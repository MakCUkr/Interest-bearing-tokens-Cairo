%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc20.IERC20 import IERC20

from contracts.interfaces.i_c_token import IcToken

const PRANK_USER_1 = 111
const PRANK_USER_2 = 222
const NAME = 109214297711982 # cToken
const SYMBOL = 1666468686 # cTKN
const DECIMALS = 18
const INITIAL_SUPPLY_LOW = 1000
const INITIAL_SUPPLY_HIGH = 0

@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        context.token = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo", [ids.NAME, ids.SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.PRANK_USER_1]).contract_address
        context.c_token = deploy_contract("./contracts/protocol/c_token.cairo", [context.token]).contract_address
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

    let (asset_after) = IcToken.UNDERLYING_ASSET_ADDRESS(c_token)
    assert asset_after = token

    let (name_set) = IcToken.name(c_token)
    assert name_set = NAME

    let (symbol_set) = IcToken.symbol(c_token)
    assert symbol_set = SYMBOL

    return ()
end

@view
func test_get_token_value{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
     
    let (local token, local c_token) = get_contract_addresses()
    let rand_uint = Uint256(100,0)
    let (equivalent_value) = IcToken.get_token_value(c_token, rand_uint)
    assert equivalent_value = Uint256(90,0)

    return ()
end


@view
func test_get_c_token_value{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
     
    let (local token, local c_token) = get_contract_addresses()
    let rand_uint = Uint256(100,0)
    let (equivalent_value) = IcToken.get_c_token_value(c_token, rand_uint)
    assert equivalent_value = Uint256(110,0)

    return ()
end


@external
func test_mint{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
     
    let (local token, local c_token) = get_contract_addresses()
    let rand_uint = Uint256(100,0)

    %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.token) %}
        IERC20.approve(token, c_token, rand_uint)
    %{ stop_prank_callable() %}

     %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.c_token) %}
        let (_mintedAmount) = IcToken.mint(c_token, PRANK_USER_1, rand_uint)
    %{ stop_prank_callable() %}

    assert _mintedAmount = Uint256(110,0)
    let (balance) = IcToken.balanceOf(c_token, PRANK_USER_1)
    assert Uint256(110,0) = balance

    return ()
end


@external
func test_burn{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
     
    let (local token, local c_token) = get_contract_addresses()
    let rand_uint = Uint256(100,0)

    test_mint()

    %{ stop_prank_callable = start_prank(ids.PRANK_USER_1, ids.c_token) %}
        let (returned_amount) = IcToken.burn(c_token, rand_uint)
    %{ stop_prank_callable() %}

    assert returned_amount = Uint256(90,0)
    let (balance) = IcToken.balanceOf(c_token, PRANK_USER_1)
    assert balance = Uint256(10,0)

    return ()
end