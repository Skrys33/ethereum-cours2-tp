pragma solidity ^0.5.0;

/*
    This contract shows an example of the TicTacToe game written in Solidity.
    Be careful while using it as it may be vulnerable to attacks.
*/
contract TicTacToe {

    Game[] public games;

    struct Game {
        uint turn;
        uint hostBalance;
        uint opponentBalance;
        address host;
        address opponent;
        address winner;
        mapping(uint => mapping(uint => address)) board;  // (Row, Column) format
    }

    constructor() public {
    }

    /*
        Check if the player is registered in the game as the opponent.
    */
    modifier isOpponent(uint gameNumber, address player){
        require(games[gameNumber].opponent == player, "Given player should be the opponent.");
        _;
    }

    /*
        Check if the two players have credited the same amount
    */
    modifier isGameBalanceEqual(uint gameNumber) {
        Game memory game = games[gameNumber];
        require(game.hostBalance == game.opponentBalance, "Balance of players for the game are not equal.");
        _;
    }

    /*
        Check if the player is registered in the game as the host.
    */
    modifier isHost(uint gameNumber, address player){
        //TODO De la même manière que isOpponent, valider que le joueur est bien le host de la partie
        require(games[gameNumber].host == player, "Given player should be the host.");
        _;
    }

    /*
        Check if the player is registered in the game either as the host or the opponent.
    */
    modifier isPlayer(uint gameNumber, address player) {
        require(games[gameNumber].host == player || games[gameNumber].opponent == player, "Given player is not part of the game.");
        _;
    }

    /*
        Host plays on even turns, opponent plays on odd turns.
        Check that the given player can play on the actual turn.
    */
    modifier isPlayerTurn(uint gameNumber, address player){
        if(games[gameNumber].turn%2 == 0 && player == games[gameNumber].host){
            _;
        }
        else if(games[gameNumber].turn%2 == 1 && player == games[gameNumber].opponent){
            _;
        }
    }

    /*
        Check if the cell is playable
    */
    modifier isCellFree(uint gameNumber, uint row, uint column){
        //TODO Valider que la case n'a jamais été jouée
        if(games[gameNumber].board[row][column] == address(0)){
            _;
        }
    }

    modifier isValueProvided(uint value) {
        if(value > 0){
            _;
        }
    }

    function getGamesNumber() public view returns (uint) {
        return games.length;
    }

    /*
        Returns the game numbers of the connected account
    */
    function getHostGamesIds() public view returns (uint[] memory idsGames) {
        //TODO Retourner un array avec les numéro de jeux auquel le compte EOA appelant la fonction est inscrit.
        idsGames = new uint[](getGamesNumber());
        uint y = 0;
        for (uint i=0; i<getGamesNumber(); i++) {
            if(games[i].host == msg.sender || games[i].opponent == msg.sender){
                idsGames[y] = i;
                y++;
            }
        }

        return idsGames;
    }

    /*
        The host can initiate the game for his address. He bet an initial amount of Ether.
    */
    function initGame(address opponent, uint amountCash) public isValueProvided(amountCash){
        //TODO Créer un jeu et l'ajouter à la liste des jeux. Ce jeu doit enregistrer la mise du joueur le créant, ainsi que son addresse et l'addresse de l'adversaire qui sera passée en parametre.
        Game memory game;
        game.hostBalance = amountCash;
        game.host = msg.sender;
        game.opponent = opponent;
        
        games.push(game);
    }

    /*
        The opponent join the game.
    */
    function joinGame(uint gameNumber, uint amountCash) public isOpponent(gameNumber, msg.sender) isValueProvided(amountCash){
        //TODO L'adversaire (un compte EOA) rejoint une partie qu'il choisit et sur laquelle il est déjà enregistré comme adversaire. Il doit mettre une mise initiale correspondant à celle mise par le Host.
        games[gameNumber].opponentBalance = amountCash;
    }

    /*
        Play on a given cell
    */
    function play(uint gameNumber, uint row, uint column)  isPlayerTurn(gameNumber, msg.sender) isGameBalanceEqual(gameNumber) isCellFree(gameNumber, row, column) public{
        //TODO Un joueur place un pion sur un jeu auquel il s'est enregistré. Les mises des deux joueurs doivent être identiques pour jouer. Il faut également valider que la case n'a jamais été jouée.
        games[gameNumber].board[row][column] = msg.sender;
        games[gameNumber].turn += 1;
    }

    function getHostId(uint gameNumber) public view returns (address hostId){
        return  games[gameNumber].host;
    }

    function getOpponentId(uint gameNumber) public view returns (address opponentId){
        return  games[gameNumber].opponent;
    }

    function getHostBalance(uint gameNumber) public view returns (uint hostBalance){
        return  games[gameNumber].hostBalance;
    }

    function getOpponentBalance(uint gameNumber) public view returns (uint opponentBalance){
        return  games[gameNumber].opponentBalance;
    }

    function getStateCell(uint gameNumber, uint row, uint column) public view returns (uint stateCell){
        if(games[gameNumber].board[row][column] == games[gameNumber].host){
            return 1;
        }else if(games[gameNumber].board[row][column] == games[gameNumber].opponent){
            return 2;
        }else{
            return 0;
        }
    }

    function getWhoCanPlay(uint gameNumber) public view returns (uint player){
        if((games[gameNumber].turn%2 == 0 && msg.sender == games[gameNumber].host) || (games[gameNumber].turn%2 == 1 && msg.sender == games[gameNumber].opponent)){
            return 0;
        }
        else {
            return 1;
        }
    }

    function getWhoWinGame(uint gameNumber) public view returns (address winner){
        
        
        if(games[gameNumber].board[0][0] == games[gameNumber].board[0][1]  && games[gameNumber].board[0][1] ==  games[gameNumber].board[0][2]){
            winner =  games[gameNumber].board[0][0];
        }else if(games[gameNumber].board[1][0] == games[gameNumber].board[1][1]  && games[gameNumber].board[1][2] == games[gameNumber].board[1][1]){
            winner = games[gameNumber].board[1][0];
        }else if(games[gameNumber].board[2][0] == games[gameNumber].board[2][1]  && games[gameNumber].board[2][2] == games[gameNumber].board[2][1]){
            winner = games[gameNumber].board[2][0];
        }else if(games[gameNumber].board[0][0] == games[gameNumber].board[1][0]  && games[gameNumber].board[2][0] == games[gameNumber].board[1][0]){
            winner = games[gameNumber].board[0][0];
        }else if(games[gameNumber].board[0][1] == games[gameNumber].board[1][1]  && games[gameNumber].board[2][1] == games[gameNumber].board[1][1]){
            winner = games[gameNumber].board[0][1];
        }else if(games[gameNumber].board[0][2] == games[gameNumber].board[1][2]  && games[gameNumber].board[2][2] == games[gameNumber].board[1][2]){
            winner = games[gameNumber].board[0][2];
        }else if(games[gameNumber].board[0][0] == games[gameNumber].board[1][1]  && games[gameNumber].board[2][2] == games[gameNumber].board[1][1]){
            winner = games[gameNumber].board[1][1];
        }else if(games[gameNumber].board[2][0] == games[gameNumber].board[1][1]  && games[gameNumber].board[0][2] == games[gameNumber].board[1][1]){   
            winner = games[gameNumber].board[1][1];
        }
                
                
        if(games[gameNumber].board[0][0] == games[gameNumber].host || games[gameNumber].board[0][0] == games[gameNumber].opponent){
            return winner;
        }else{
            return address(0);
        }

        
    }
}