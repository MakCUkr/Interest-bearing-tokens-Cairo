%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace I4626:
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

    func asset() -> (res : felt):
    end

    func convertToAssets(share_amt: Uint256) -> (equiv_asset_value : Uint256):
    end

    func convertToShares(asset_amt: Uint256) -> (equiv_share_value : Uint256):
    end

    func previewDeposit(asset_amt: Uint256) -> (equiv_share_value : Uint256):
    end

    func previewMint(asset_amt: Uint256) -> (equiv_share_value : Uint256):
    end

    func previewWithdraw(share_amt: Uint256) -> (equiv_asset_value : Uint256):
    end

    func previewRedeem(share_amt: Uint256) -> (equiv_asset_value : Uint256):
    end
    
    func totalAssets() -> (res : Uint256):
    end
    
    func maxDeposit() -> (max_deposit : Uint256):
    end

    func maxMint() -> (max_deposit : Uint256):
    end
    
    func maxWithdraw() -> (max_deposit : Uint256):
    end

    func maxRedeem() -> (max_deposit : Uint256):
    end

    func deposit(assets: Uint256, receiver: felt) -> (shares : Uint256):
    end

    func mint(assets: Uint256, receiver: felt) -> (shares : Uint256):
    end

    func withdraw(assets: Uint256, receiver: felt, owner: felt) -> (shares : Uint256):
    end
    
    func redeem(assets: Uint256, receiver: felt, owner: felt) -> (shares : Uint256):
    end

end