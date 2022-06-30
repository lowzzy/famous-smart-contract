
///////////////////////////////////////////////////////////////////////////
//                                                                       //
// ███████╗██╗   ██╗███╗   ███╗ ██████╗ ██╗      █████╗ ██████╗ ███████╗ //
// ██╔════╝██║   ██║████╗ ████║██╔═══██╗██║     ██╔══██╗██╔══██╗██╔════╝ //
// ███████╗██║   ██║██╔████╔██║██║   ██║██║     ███████║██████╔╝███████╗ //
// ╚════██║██║   ██║██║╚██╔╝██║██║   ██║██║     ██╔══██║██╔══██╗╚════██║ //
// ███████║╚██████╔╝██║ ╚═╝ ██║╚██████╔╝███████╗██║  ██║██████╔╝███████║ //
// ╚══════╝ ╚═════╝ ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝ //
//                                                                       //
//                  OPSumoClub contract by 0xSumo                        //
//                  Twitter : https://twitter.com/0xSumo                 //
//                  Discord : 0xSumo#9999                                //
//                                                                       //
///////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.7;

import "./ERC721.sol";
import "./Ownable.sol";


contract OPSumoClub is ERC721, Ownable {

    uint256 public mintPrice = 0 ether;
    uint256 private maxToken = 333;
    uint256 public publicSale;
    string private baseTokenURI;
    string private baseTokenURI_EXT;
    bool public publicSaleEnabled = false;
    mapping(address => uint256) public psMinted;
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private supply;

    constructor () ERC721 ("OPSumoClub","OPSC") {}

    function ownerMint(uint256 _amount, address _address) public onlyOwner {
        require((_amount + supply.current()) <= (maxToken), "No more NFTs");
        internalmint(_address, _amount);
    }

    function publicMint(uint256 _amount) public payable onlySender {
        require(publicSaleEnabled, "publicMint: Paused");
        require(_amount <= 1, "more than max per transaction");
        require(psMinted[msg.sender] == 0, "You have no mints remaining!");
        require(msg.value == mintPrice * _amount, "Value sent is not correct");
        require((_amount + supply.current()) <= (maxToken), "No more NFTs");

        psMinted[msg.sender] += _amount;
        internalmint(msg.sender, _amount);
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    function setPublicSale(bool bool_) external onlyOwner {
        publicSaleEnabled = bool_;
    }

    function setBaseURI(string memory uri_) public onlyOwner {
        baseTokenURI = uri_;
    }

    function setbaseTokenURI_EXT(string memory ext_) public onlyOwner {
        baseTokenURI_EXT = ext_;
    }

    function totalSupply() public view returns (uint256) {
        return supply.current();
    }

    function currentBaseURI() private view returns (string memory){
        return baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(currentBaseURI(), Strings.toString(tokenId), baseTokenURI_EXT));
    }

    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    modifier onlySender {
        require(msg.sender == tx.origin, "No smart contract"); _;
    }

    function internalmint(address _address, uint256 _amount) internal {
        for (uint256 i = 0; i < _amount; i++) {
          supply.increment();
          _safeMint(_address, supply.current());
        }
    }

    function walletOfOwner(address _address) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_address);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;
        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxToken) {
            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _address) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;
                ownedTokenIndex++;
            }
            currentTokenId++;
        }
        return ownedTokenIds;
    }
}
