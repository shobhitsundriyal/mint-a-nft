// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "./Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract OrbNfts is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address owner;
  uint public glowingCost;
  uint public normalCost;
  uint public maxSupply;
  uint public glmaxSupply;
  uint noOfGlowing;
  uint noOfNormal;
  //for generation
  //for normal
  uint a;
  uint mod;
  uint seed;
  uint adder;
  //for glowing
  uint ga;
  uint gmod;
  uint gseed;
  uint gadder;


  // We need to pass the name of our NFTs token and its symbol.
  constructor() ERC721 ("newNFT", "nfts") {
    owner = msg.sender;
    glowingCost = 0.5 ether;
    normalCost = 0.1 ether;

    maxSupply = 141;
    glmaxSupply = 141;

    a = 5;
    mod = 37;
    seed = 5;
    adder = 0;

    ga = 5;
    gseed = 17;
    gadder = 0;

    noOfGlowing = 0;
    noOfNormal = 0;

    console.log("This is my NFT contract. Woah!");
  }

  function generateGlowingImage(uint _hueVal) internal view returns (string memory){
    string memory encodedImg = Base64.encode(
      bytes(
        abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500"><linearGradient xmlns="http://www.w3.org/2000/svg" id="a" x1="50%" y1="100%" x2="85%" y2="0%"><stop offset="0%" style="stop-color:hsl(',Strings.toString(_hueVal),',82.6%,20%)"/><stop offset="100%" style="stop-color:hsl(',Strings.toString(_hueVal+adder),',82.6%,78%)"/></linearGradient><filter id="f1" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="25"/></filter><rect width="500" height="500" rx="15" fill="#161b1d"/><circle cx="250" cy="250" r="205" fill="url(#a)" filter="url(#f1)"/><circle cx="250" cy="250" r="200" fill="url(#a)"/><ellipse cx="320" cy="100" rx="20" ry="60" fill="#fff" transform="rotate(-70 300 100)" opacity=".48"/></svg>')
      )
    );
    //console.log('Only Image encoded',encodedImg);
    return encodedImg;
  }

  function generateNormalImage(uint _hueVal) internal view returns (string memory){
    string memory encodedImg = Base64.encode(
      bytes(
        abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500"><linearGradient xmlns="http://www.w3.org/2000/svg" id="a" x1="50%" y1="100%" x2="85%" y2="0%"><stop offset="0%" style="stop-color:hsl(',Strings.toString(_hueVal),',82.6%,20%)"/><stop offset="100%" style="stop-color:hsl(',Strings.toString(_hueVal+adder),',82.6%,78%)"/></linearGradient><rect width="500" height="500" rx="15" fill="#161b1d"/><circle cx="250" cy="250" r="200" fill="url(#a)"/><ellipse cx="320" cy="100" rx="20" ry="60" fill="#fff" transform="rotate(-70 300 100)" opacity=".48"/></svg>')
      )
    );
    //console.log('Only Image encoded',encodedImg);
    return encodedImg;
  }

  function generateGlowingMetaData(string memory _image) internal view returns(string memory){
    string memory encoded = Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name":"Glowing Orb #',Strings.toString(noOfGlowing),'", "description":"This is an Lucky Orb","image":"data:image/svg+xml;base64,',(_image),'","attributes":[{"value":"Glowing"},{"value":"Super Lucky"}]}'
            )
          )
        );
    string memory meta = string(
      abi.encodePacked(
        'data:application/json;base64,',encoded ));
    //console.log('Meta: ',meta);
    return meta;
  }

  function generateNormalMetaData(string memory _image) internal view returns(string memory){
    string memory encoded = Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name":"Orb #',Strings.toString(noOfNormal),'", "description":"This is an Lucky Orb","image":"data:image/svg+xml;base64,',(_image),'","attributes":[{"value":"Lucky"}]}'
            )
          )
        );
    string memory meta = string(
      abi.encodePacked(
        'data:application/json;base64,',encoded ));
    //console.log('Meta: ',meta);
    return meta;
  }

  function generateGlowingURI( ) internal returns(string memory) {
    noOfGlowing += 1;
    if(gseed == 5){
      gadder += 60;
    }
    gseed = (gseed*a)%mod;
    uint hueVal = gseed * 10;
    console.log('HUE:',hueVal);
    string memory image = generateGlowingImage(hueVal);
    return generateGlowingMetaData(image);

  }

  function generateNormalURI( ) internal returns(string memory) {
    noOfNormal += 1;
    if(seed == 5){
      adder += 60;
    }
    seed = (seed*a)%mod;
    uint hueVal = seed * 10;
    console.log('HUE:',hueVal);
    string memory image = generateNormalImage(hueVal);
    return generateNormalMetaData(image);

  }

  // A function our user will hit to get their NFT.
  // 0-> normal lucky, 1(else)-> glowing superlucky
  function makeAnEpicOrb(uint _type) public payable {
    if (msg.sender != owner){
      if(_type == 1){
        require(msg.value >= glowingCost, "Please pay the required cost of nft");
        require(noOfGlowing < glmaxSupply, "All glowing orbs have been minted");
      }
      else{
        require(msg.value >= normalCost, "Please pay the required cost of nft");
        require(noOfNormal < maxSupply, "All orbs have been minted");
      }
    }
     // Get the current tokenId, this starts at 0.
    uint256 newItemId = _tokenIds.current();

     // Actually mint the NFT to the sender using msg.sender.
    _safeMint(msg.sender, newItemId);

    // Set the NFTs data.
    if(_type == 0){
      _setTokenURI(newItemId, generateNormalURI());
      console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    }
    else{
      _setTokenURI(newItemId, generateGlowingURI());
      console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    }
    // Increment the counter for when the next NFT is minted.
    _tokenIds.increment();
  }

  //function makeAnLegendaryOrb(address _mintTo, string _uri) public WORK IN PROGRESS

  function changeGlowingCost(uint _newCost) public {
    require(msg.sender == owner,"You can't change the price");
    glowingCost = _newCost * 1000000000000000000;
  }

  function changeNormalCost(uint _newCost) public {
    require(msg.sender == owner,"You can't change the price");
    normalCost = _newCost * 1000000000000000000;
  }

  function payOwner() public {
    require(msg.sender == owner, 'You are not allowed to execute this');
    payable(owner).transfer(contractBalance());
  }

  function contractBalance () public view returns(uint){
    return address(this).balance;
  }
}