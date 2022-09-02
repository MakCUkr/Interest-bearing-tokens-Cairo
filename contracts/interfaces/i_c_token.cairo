%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IcToken:
    func name() -> (name : felt):
    end

    func symbol() -> (symbol : felt):
    end

    func totalSupply() -> (totalSupply : Uint256):
    end

    func decimals() -> (decimals : felt):
    end

    func balanceOf(account : felt) -> (balance : Uint256):
    end

    func allowance(owner : felt, spender : felt) -> (remaining : Uint256):
    end

    func UNDERLYING_ASSET_ADDRESS() -> (res : felt):
    end

    func transfer(recipient : felt, amount : Uint256) -> (success : felt):
    end

    func transferFrom(sender : felt, recipient : felt, amount : Uint256) -> (success : felt):
    end

    func approve(spender : felt, amount : Uint256) -> (success : felt):
    end

    func increaseAllowance(spender : felt, added_value : Uint256) -> (success : felt):
    end

    func decreaseAllowance(spender : felt, subtracted_value : Uint256) -> (success : felt):
    end

    func get_token_value(c_token_amount: Uint256) -> (equiv_token_value : Uint256):
    end

    func get_c_token_value(token_amount: Uint256) -> (equiv_c_token_value : Uint256):
    end
end