//                                    ...........................                                     
//                          .*/(((((((#&@@@@&%#%&@&%#(%&@@@@&%##(((((/,.                              
//                       .,/(#&&&&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&&&%%%%/,                        
//                    ,*(#%%&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#(*.                     
//                    *#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#*                     
//                    *#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#*     ...             
//            ...     *#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#*                     
//           .,****,,,*/((((#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#((((/*.,,****,.            
//          .*(%#(/**,,,,*,,*/(###%%%%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%%%#####/*,,,,*(%%%%(*.           
//        ,*/#&@&%#(/*,,,,,.,,**/((##%%&&%%%%%%%%%%&&&&&&&&&@@@@@@&%#(((((((/*,**/#%@@@@&#/*,         
//       ,(&@@@@@@@&#(/*,,,,,,,*/(%&&@&%#(*,,,****/(#%%%%%%%%%&&%%%#((###/*,,**(%@@@@@@@@@@&(,        
//       ,(&@@@@@@@@@@&#//*****/(%&&@@@@@&%#(*,,,*/(#%%%%%%%%%&%%%##((//***/(%@@@@@@@@@@@@@&(,        
//       ./#%&&&&@@%(/*********/(%&&@@@@@@&&%#(/*,*/#%%#%%&&&%%%######(/***/#&@&%####%%&&&&%(,.       
//       .,/(#%%#(/*,.,/###%#(//#%%&@@@@@@@@&%%#((((((#%&&&&%%#######((//(#%&@@&#(/*,,***///*,..      
//       .,*//((//*,. ,/#%&@@&##%%%&@@@@@@@@&%##%%%#//(#%%###############&@@@&%#(/,.     ..,...       
//       .*(#/**(%&#*... *(%&&&&&%%&@@@&&&&&%#/(%@&#/**,*//(((((#####%&&@@@&#(**,...     ....         
//         .*(%&(*.*(%(*.....,*/(%&&@@%(****(%@@@@&(.          ..,*/##(/////*,,,......    ..          
//           .,,.   ....... ..,,*///(//*,/#&&@@@@@&/.              ..,,,,,,,,,..                      
//                 .,/*, .............*/#%&@@@@@@@&(,                   ...,*/((((*.                  
//                 ,*(/*,,,...  .....,/#&&&&&&@&&&#/,       ........    .,*/#&@&%#/,                  
//                    ,/#(/*,,,,,*//(((((###%%%%##/*. .,,,,,,******,,,,,*(%@@&&(,                     
//                       *(&%(,..,,*/(((((##%&@@@@&#/,,***********,,,...*(%&(*                        
//                        .,*(%#/*,,,*/(((((#%&@@@&#/*************,,,...,,,,.                         
//                          .,//(((/,,*/((((##%%%%%(/**********,,.......                              
//                             .*#%#(////((((#####(/*****,,,,,,,.  ...                                
//                               .,(%&#/**/((((((((/****,,.......,....                                
//                                 .,*(%@#/,*/(((((/****,.      ...                                   
//                                    ,*/**,*/(((((/*,,..                                             
//                                      ...,,**/(((/*,..                                              
//                                        ...,,,*//*,..                                               
//                                           ..,,...

// UNISWAP EMERALDS - FUNGIBLE NON-FUNGIBLE TOKEN
// T.ME/PARTYHAT THIS CONTRACT IS A TEST
// NOT AN INVESTMENT, FUNCTION NOT GUARANTEED

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library LibTransfer20 {
    event Transfer(address indexed from, address indexed to, uint amount);

    function emitTransfer(address _from, address _to, uint _amount) internal {
        emit Transfer(_from, _to, _amount);
    }
}

library LibTransfer721 {
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    function emitTransfer(address _from, address _to, uint _tokenId) internal {
        emit Transfer(_from, _to, _tokenId);
    }
}

contract sEReC20721_emerald_test {

    string internal constant _name = "Uniswap Emeralds";
    string internal constant _symbol = "EMERALD";

    uint internal constant _decimals = 6;
    uint internal constant _subDecimals = 4; 

    uint internal constant _totalSupply = 7777 * 10**_decimals;
    
    uint constant ONE = 10**_decimals; 
    uint constant MAXID = ONE + (_totalSupply / 10**_decimals); 

    string public baseURI = "https://raw.githubusercontent.com/SerecThunderson/assets/main/emeralds/metadata/";
    address public dev;
    uint32 private minted;

    uint32[] private broken; // store nft ids lost in limbo

    mapping(address => uint) internal _balanceOf;
    mapping(address => mapping(address => uint)) internal _allowance;
    mapping(uint256 tokenId => address) public ownerOf;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(address => uint32[]) public ownedNFTs;

    mapping(uint32 => uint256) private idToIndex; 

    event Approval(address indexed owner, address indexed spender, uint256 indexed amount, uint256 id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    //@dev declare roll under/roll over events as break/make

    modifier onlyDev() {
        require(msg.sender == dev, "Not the developer");
        _;
    }

    constructor() {
        minted = uint32(ONE);
        _balanceOf[msg.sender] = _totalSupply; 
        dev = msg.sender;

    }

    function name() public view virtual returns (string memory) { return _name; }
    function symbol() public view virtual returns (string memory) { return _symbol; }
    function decimals() public view virtual returns (uint) { return _decimals; }
    function totalSupply() public view virtual returns (uint) { return _totalSupply; }
    function balanceOf( address account) public view virtual returns (uint) { return _balanceOf[account]; }
    function allowance(address owner, address spender) public view virtual returns (uint) { return _allowance[owner][spender]; }
    function setBaseURI(string memory newBaseURI) public onlyDev {baseURI = newBaseURI;}

    function approve(address spender, uint amount) public virtual returns (bool) {

        //if the amount is greater than one token, and within range of IDs for NFTs 
        //then set NFT approval for the given ID
        if(amount > ONE && amount < MAXID) {
            address owner = ownerOf[amount];
            if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert("sEReC20721: You are not approved");
            _tokenApprovals[amount] = spender;
            emit Approval(owner, spender, ONE, amount);
            return true;
        }
        
        //set the allowance
        //the NFT ID range being set within a limited subset of ONE token(s)
        //allows for non-clashing interactions
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount, 0);
        return true;
    }

    event Event(string, uint);

    function _transfer20721(address from, address to, uint amount) internal virtual {
        
        require(_balanceOf[from] >= amount, "sEReC20721: transfer amount exceeds balance");
        
        //checking the decimal amount of tokens owned before transaction for both participants
        uint256 fromDecimalsInit = _balanceOf[from] % ONE;
        uint256 toDecimalsInit = _balanceOf[to] % ONE;
        
        //simple erc20 balance operations
        _transfer20(from, to, amount);

        //checking the decimal amount of tokens after transaction for both partcipants
        uint256 fromDecimalsPost = _balanceOf[from] % ONE;
        uint256 toDecimalsPost = _balanceOf[to] % ONE;

        // if sender has less decimal amount then they "rolled under" and break an NFT
        if (fromDecimalsInit < fromDecimalsPost) {
            emit Event("roll under", 0);

            if(ownedNFTs[from].length > 0) { // if the sender has an nft to send

                uint32 tokenId = ownedNFTs[from][0];//selects the user's first NFT from the list

                broken.push(tokenId);//pushes the nft into the "broken list" for limbo NFTs
                _transfer721(from, address(0), tokenId);//transfers the NFT ID ownership to (0) address for stewardship

                emit Event("transfer to broken", tokenId);

                assert(broken[broken.length - 1] == tokenId);
            }
            else { // if they dont have an nft, but should, then mint and break it

                uint32 tokenId = _mint(address(0));
                broken.push(tokenId);
                emit Event("mint to broken", tokenId);

                assert(broken[broken.length - 1] == tokenId);
            }

        }

        // if receiver has more decimal amount then they "rolled over" and will "remake" an nft 
        if (toDecimalsInit > toDecimalsPost) {
            emit Event("roll over", 0);

            if(broken.length > 0) { // recover an id from broken list
                uint32 tokenId = broken[broken.length - 1];

                broken.pop();

                _transfer721(address(0), to, tokenId);

                emit Event("from broken", tokenId); //rename "make"

                assert(ownerOf[tokenId] == to);
                assert(ownedNFTs[to][ownedNFTs[to].length - 1] == tokenId); //I like the assertion checks
            }
            else { // mint new id

                uint32 tokenId = _mint(to);
                emit Event("mint new", tokenId);

                assert(ownerOf[minted] == to);
                assert(ownedNFTs[to][ownedNFTs[to].length - 1] == minted);
            }
            
        }
        
        //@NOTICE amount of tokens - amount of whole tokens being processed in int
        uint amountInTokens = amount / ONE;

        //@NOTICE ignore minting nfts to and from dev when they call
        // @DEV I think it should just be if from == dev -- one-way gem-cutting process
        //      I have genuine concern with list parity with this implementation
        if(from == dev){
            return;
        }

        //@NOTICE handle erc721 txns
        for (uint i = 0; i < amountInTokens; i++) {
            
            if(ownedNFTs[from].length > 0){ // transfer token
                emit Event("ownedNFTs[from].length", ownedNFTs[from].length); // @DEV remove for production
                uint32 tokenId = ownedNFTs[from][0];
                _transfer721(from, to, tokenId); 

                assert(ownerOf[tokenId] == to);
            }
            else if(broken.length > 0) { // recover token from broken list
                emit Event("broken.length", broken.length); // @DEV remove for production
                uint32 tokenId = broken[broken.length - 1];
                broken.pop();

                _transfer721(address(0), to, tokenId);

                assert(ownerOf[tokenId] == to);
            }
            else { // mint new tokens
                _mintBatch(to, amountInTokens - i);
                break;
            }
        }        
    }

    function _mintBatch(address to, uint256 amount) internal {
        if(amount == 1) {
            _mint(to);
            return;
        }
        uint32 id = minted;
        uint256 ownedLen = ownedNFTs[to].length;
        for(uint i = 0; i < amount;) {
            unchecked {
                id++;
            }
            ownerOf[id] = to;
            idToIndex[id] = ownedLen;
            ownedNFTs[to].push(id);

            unchecked {
                ownedLen++;
                i++;
            }
        }
        unchecked {
            minted += uint32(amount);
        }
    }

    function _mint(address to) internal returns(uint32 tokenId){
        unchecked {
            minted++;
        }
        tokenId = minted; 

        ownerOf[tokenId] = to;
        idToIndex[tokenId] = ownedNFTs[to].length;
        ownedNFTs[to].push(tokenId);
        
        LibTransfer721.emitTransfer(address(0), to, tokenId);
        assert(ownerOf[tokenId] == to);
    }

    //elegantly handle nft updates
    //ensure break/make takes this into account
    function _updateOwnedNFTs(address from, address to, uint32 tokenId) internal {

        uint256 index = idToIndex[tokenId];
        uint256 len = ownedNFTs[from].length;
        uint32 lastTokenId = ownedNFTs[from][len - 1];
        
        ownedNFTs[from][index] = lastTokenId;
        ownedNFTs[from].pop();
        
        if(len - 1 != 0){
            idToIndex[lastTokenId] = index;
        }

        ownedNFTs[to].push(tokenId);
        idToIndex[tokenId] = ownedNFTs[to].length - 1;
    }

    // simple erc20 txn
    function _transfer20(address from, address to, uint256 amount) internal {
        _balanceOf[from]-= amount; 
        
        unchecked {
            _balanceOf[to]+= amount;
        }
        LibTransfer20.emitTransfer(from, to, amount);
    }

    function _transfer721(address from, address to, uint32 tokenId) internal virtual {
        require(from == ownerOf[tokenId],"sEReC20721: Incorrect owner");
        
        delete _tokenApprovals[tokenId];
        ownerOf[tokenId] = to;
        _updateOwnedNFTs(from, to, tokenId);
        LibTransfer721.emitTransfer(from, to, tokenId);
    }

    // only erc20 calls this
    // if amount is a token id owned my the caller send as an NFT
    // else transfer20721
    function transfer(address to, uint amount) public virtual returns (bool) {
        //if(amount > ONE && amount < MAXID) 
        @serec
        if(ownerOf[amount] == msg.sender) {
            _transfer721(msg.sender, to, uint32(amount));
            _transfer20(msg.sender, to, ONE);
            return true;
        }
        _transfer20721(msg.sender, to, amount);
        return true;
    }

    // erc20 and erc721 call this
    function transferFrom(address from, address to, uint amount) public virtual returns (bool) {
        uint startFrom = balanceOf(from);
        uint startTo = balanceOf(to);

        //if amount is within the NFT id range, then a simple NFT transfer + token amount (ONE)
        if(amount > ONE && amount < MAXID) {
            require(
                //require from is the msg caller, or that caller is approved for that specific NFT, or all NFTs 
                msg.sender == from || msg.sender == getApproved(amount) || isApprovedForAll(from, msg.sender),
                "sEReC20721: You don't have the right"
                );

            _transfer721(from, to, uint32(amount));
            _transfer20(from, to, ONE);
            
            assert(balanceOf(from) == startFrom - ONE);
            assert(balanceOf(to) == startTo + ONE);
            assert(ownerOf[amount] == to);
            return true;
        }

        //covered before
        _spendAllowance(from, msg.sender, amount);
        _transfer20721(from, to, amount);

        assert(balanceOf(from) == startFrom - amount);
        assert(balanceOf(to) == startTo + amount);
        return true;

    }

    //erc721
    function safeTransferFrom(address from, address to, uint32 tokenId) public virtual returns (bool) {
        require(
                msg.sender == from || msg.sender == getApproved(tokenId) || isApprovedForAll(from, msg.sender),
                "sEReC20721: You don't have the right"
            );
        _transfer721(from, to, tokenId); 
        _transfer20(from, to, ONE);
        return true;
    }

    //erc721
    function safeTransferFrom(address from, address to, uint32 tokenId, bytes memory data) public virtual {
        require(
                msg.sender == from || msg.sender == getApproved(tokenId) || isApprovedForAll(from, msg.sender),
                "sEReC20721: You don't have the right"
            );
        _transfer721(from, to, tokenId); 
        _transfer20(from, to, ONE);
    }

    function _spendAllowance(address owner, address spender, uint amount) internal virtual {
        require(_allowance[owner][spender] >= amount, "sEReC20721: insufficient allowance");
        _allowance[owner][spender] -= amount;
    }

    function getApproved(uint256 tokenId) public view virtual returns (address) {
        if (ownerOf[tokenId] == address(0)) revert();
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        if (bytes(baseURI).length == 0) {return "";}
        return string(abi.encodePacked(baseURI, toString(tokenId - ONE), ".json"));
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {return "0";} uint256 temp = value; uint256 digits;
        while (temp != 0) {digits++; temp /= 10;} bytes memory buffer = new bytes(digits);
        while (value != 0) {digits -= 1; buffer[digits] = bytes1(uint8(value % 10) + 48); value /= 10;}
        return string(buffer);
    }

    function withdraw() external onlyDev {
        payable(dev).transfer(address(this).balance);
    }

    function echidna_matching_nft_and_token_balance() public view returns (bool) {
        if (msg.sender != dev && balanceOf(msg.sender) > ONE) {
            return ownedNFTs[msg.sender].length == balanceOf(msg.sender) / ONE;
        }
        return true;
    }

    function echidna_correct_nft_ownership() public view returns (bool) {
        
        // Iterate through all minted NFT IDs
        for (uint256 i = ONE + 1; i <= minted; i++) {
            address owner = ownerOf[i];
            bool found = false;
            

            if(owner == address(this)) {
                for (uint256 j = 0; j < broken.length; j++) {
                    if(broken[j] == i) {
                        found = true;
                        break;
                    }
                }
            }
            else if(owner == address(0)){ found = true; }
            
            // Check if the NFT ID is in the owner's list of owned NFTs
            for (uint256 j = 0; j < ownedNFTs[owner].length; j++) {
                if (ownedNFTs[owner][j] == i) {
                    found = true;
                    break;
                }
            }
        
            if (!found) return false;
            
        }
        return true;
    }

    function echidna_minted_limit() public view returns (bool) {
        return minted-ONE <= _totalSupply / ONE;
    }
}

//@DEV --    
//        use address(0) for the events to/from, and ownership of the NFT for break/make -- but use the broken list for the list
//        this allows automatic untracking of limbo-NFTs, but still full-on burning of NFT-tokens to address(0) never to be recovered
