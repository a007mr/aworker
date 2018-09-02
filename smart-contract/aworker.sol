pragma solidity ^0.4.21;
contract Company{
    
    uint public ID = 0;
    uint public userID = 0;
    mapping (address => uint) balances;
    address private my ;
    address aworker;
 address tradeAddress; 
     function Company() public{
        my = msg.sender;
        tradeAddress = 0x2303eD49f9cFCc0D795bCD7Af7fCb7Ce13A9Fa5a;
        aworker = 0x757bf4f2CF2F7cd2BB82A85e80cB77939bbdfd1F;
    }
    
   
    
    modifier onlyOwner() {
    require(msg.sender == my);
    _;
    }
    
       
    uint8 public aworkerRate = 10; // +
    uint8 public whoRecommendWinnerRate = 20; // +
    uint8 public recommendOnInterviewRate = 10; // +
    uint8 public winnerRate = 50; // +
    uint8 public goInterviewRate = 10;//+
    
    uint8 public aworkerCancelRate = 50;
    uint8 public senderCancelRate = 50;
    struct User{
        address userAddress;
        mapping (uint => bool) interviewIsCompleted;
    }
    
    mapping(uint=>User) public userList;
    
    struct Vacancy{
        uint id;
        address owner;
        string text;
        address winner;
        address[] who_recommend_winner;
        address[] recommend_on_interview;
        uint reward;
        bool completed;
        address[] arbitres;
        mapping(address => address[]) recommendUsersList;
        address[] interview;
    }
    mapping(uint=>Vacancy) public IDList;
    mapping(uint => address[]) public recommendUsersArray;
    
    
        function setRate(uint8 _aworkerRate,uint8 _whoRecommendWinnerRate,
        uint8 _recommendOnInterviewRate,uint8 _winnerRate,uint8 _goInterviewRate) onlyOwner
        public {
            if(_aworkerRate + _whoRecommendWinnerRate + _recommendOnInterviewRate + _winnerRate + _goInterviewRate == 100){
        aworkerRate = _aworkerRate;
        whoRecommendWinnerRate =_whoRecommendWinnerRate;
        recommendOnInterviewRate = _recommendOnInterviewRate;
        winnerRate = _winnerRate;
        goInterviewRate = _goInterviewRate;
        } else return;
    }
    
    //             function getAworkerRate() public view returns(uint8){
    //     return aworkerRate;
    // }
    //         function getRecommendOnInterviewRate() public view returns(uint8){
    //     return recommendOnInterviewRate;
    // }
    //         function getGoInterviewRate() public view returns(uint8){
    //     return goInterviewRate;
    // }
    //         function getAworkerCancelRate() public view returns(uint8){
    //     return aworkerCancelRate;
    // }
    //         function getSenderCancelRate() public view returns(uint8){
    //     return senderCancelRate;
    // }
    //         function getWhoRecommendWinnerRate() public view returns(uint8){
    //     return whoRecommendWinnerRate;
    // }
    //             function getWinnerRate() public view returns(uint8){
    //     return winnerRate;
    // }
    
        function createUser() public{
        bool flag = false;
        for(uint i = 0; i < userID; i++){
            if(msg.sender == userList[i].userAddress){
                flag = true;
                return;
            }
        }
        
        if(flag == false){
            User memory user;
            user.userAddress = msg.sender;
            userList[userID] = user;
            userID++;
        }
    }
    
    modifier isUserRegistred(){
        bool flag = false;
        for(uint i = 0; i < userID; i++){
            if(msg.sender == userList[i].userAddress){
                flag = true;
            }
        }
        require(flag == true);
        _;
    }
    
    function createVacancy(uint _reward, string _text) public isUserRegistred{
        require(balances[msg.sender] >= _reward);
        
        // bool flag = false;
        // for(uint i = 0; i < userID; i++){
        //     if(msg.sender == userList[i].userAddress){
        //         flag = true;
        //     }
        // }
        
        // require(flag == true);
        balances[tradeAddress] += _reward;
        balances[msg.sender] -= _reward;
        Vacancy memory v;
        v.owner = msg.sender;
        v.text = _text;
        v.reward = _reward;
        v.completed = false;
        v.id = ID;
        IDList[ID] = v;
        ID++;
    }
    uint[]  public masCurrentId;
    function getCurrentVacancies(address _address) public  returns(uint[]){
        delete masCurrentId;
        
            for(uint i=0; i<ID;i++){
                if(IDList[i].owner == _address){
                    if(IDList[i].completed == false){
                        masCurrentId.push(IDList[i].id);
                    }
                }    
            }
        
        return masCurrentId;
    }
    
    // НЕ  СДЕЛАНО УСЛОВИЕ КОГДА interviewIsCompleted БУДЕТ СТАНОВИТСЯ TRUE ПО КОДУ
    uint[] public workId;
    function checkUser(address _address) public  returns(uint[]){
        delete workId;
        for(uint i=0; i< userID; i++){
                for(uint k=0;k<ID;k++){
                if(userList[i].userAddress == _address && userList[i].interviewIsCompleted[k] == true){
                    workId.push(k);
                }
            }
        }
        return workId;
    }
    
    
    // Тестовая функция для добавление токенов на кошелек, т.к. смарт-контрактра токенов пока нет
    function addToken(address _address, uint _count) public {
        balances[_address] += _count;
    }
    // Эта функция тоже должна быть в смарт-контракте токена
    function balance_of(address ad) public constant returns(uint){
        return balances[ad];
    }
    
    function get_vacancy_text_by_id(uint id) public constant returns(string){
        return IDList[id].text;
    }
    
    function get_sold_of_winner(uint id) public view returns(uint){
        return balances[IDList[id].winner];
    }
    
    
    function completeUserInterview(uint _idVacancy, address _address) private{
        for(uint i=0; i< userID; i++){
            if(userList[i].userAddress == _address){
                userList[i].interviewIsCompleted[_idVacancy] = true;
                break;
            }
        }
    }
    
    function getArbitres(uint id)public constant returns(address[]){
        return IDList[id].arbitres;
    }//+
    
    function recommendCompany(uint _id, address _addPerson) public isUserRegistred{
        IDList[_id].recommendUsersList[msg.sender].push(_addPerson);
        bool flag = false;
        for(uint j = 0; j < recommendUsersArray[_id].length; j++){
            if(recommendUsersArray[_id][j] == _addPerson){
                flag = !flag;
                break;
            }
        }
        
        if(!flag){
            recommendUsersArray[_id].push(_addPerson);
        }
        
        flag = false;
        
        for(uint i = 0; i < IDList[_id].arbitres.length; i++){
            if(msg.sender == IDList[_id].arbitres[i]){
                flag = true;
                break;
            }
        }
        if(!flag) IDList[_id].arbitres.push(msg.sender);
        
    } // +
    
    function choose_winner(uint id, address _address) public isUserRegistred{
        require(msg.sender == IDList[id].owner);
        for(uint i = 0; i < IDList[id].interview.length; i++){
            if(_address == IDList[id].interview[i]){
                IDList[id].completed = true;
                if(IDList[id].completed == true){
                    for(i = 0; i < IDList[id].arbitres.length; i++){
                        address arbitr = IDList[id].arbitres[i];
                        bool flag = false;
                        for(uint j = 0; j < IDList[id].recommendUsersList[arbitr].length; j++){
                            if(_address == IDList[id].recommendUsersList[arbitr][j]){
                                IDList[id].winner = _address;
                                
                                completeUserInterview(id,_address);
                                
                                flag = true;
                                break;
                            }
                        }
                        if(flag == true){
                            //IDList[id].who_recommend_winner = arbitr;
                            IDList[id].who_recommend_winner.push(arbitr);
                            break;
                        }
                    }
                }
                
            }
        }
    }
    function give_reward(uint id) public {
        require(msg.sender == IDList[id].owner);
        balances[IDList[id].winner] += IDList[id].reward * winnerRate/100;
        
        uint count_who_reccomend_winner = IDList[id].who_recommend_winner.length;
        
         uint summary_reward_who_recommend_winner = IDList[id].reward * whoRecommendWinnerRate/100;
         uint sum_for_who_recommend_winner = summary_reward_who_recommend_winner/count_who_reccomend_winner;
        
        for(uint i = 0; i < count_who_reccomend_winner; i++){
             balances[IDList[id].who_recommend_winner[i]] += sum_for_who_recommend_winner; 
        }
        
        uint count_recommend_on_interview = IDList[id].recommend_on_interview.length;
        
        uint summary_reward_for_recommend_on_interview = IDList[id].reward * recommendOnInterviewRate/100;
        uint sum_for_recommend_on_interview =  summary_reward_for_recommend_on_interview / count_recommend_on_interview;
        
        for( i = 0; i < count_recommend_on_interview; i++){
            balances[IDList[id].recommend_on_interview[i]] += sum_for_recommend_on_interview;
        }
        uint count_interviewers = IDList[id].interview.length;
        
        uint summary_reward_for_going_interview = IDList[id].reward * goInterviewRate/100;
        uint sum_for_interviewer =  summary_reward_for_going_interview / count_interviewers;
        
        for(i = 0; i < count_interviewers; i++){
            if(IDList[id].interview[i] == IDList[id].winner){
                continue;
            } else {
            balances[IDList[id].interview[i]] += sum_for_interviewer;
            }
        }
        //aworker = 0x583031d1113ad414f02576bd6afabfb302140225;
        balances[aworker] += IDList[id].reward * aworkerRate/100;
        //tradeAddress = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
        balances[tradeAddress] -= IDList[id].reward;
    }
    
    function go_to_interview(uint id, address _address) public isUserRegistred{
        address arbitr;
        require(msg.sender == IDList[id].owner);
        for(uint i = 0; i < IDList[id].arbitres.length; i++){
            arbitr = IDList[id].arbitres[i];
            for(uint j = 0; j < IDList[id].recommendUsersList[arbitr].length; j++){
                if(_address ==  IDList[id].recommendUsersList[arbitr][j]){
                    IDList[id].interview.push(_address);
                    
                    bool flag = false;
                    for(uint k = 0; k < IDList[id].recommend_on_interview.length; k++){
                        if(arbitr == IDList[id].recommend_on_interview[k]){
                            flag = true;
                            break;
                        }
                    }
                    if(!flag) IDList[id].recommend_on_interview.push(arbitr);
                }    
            }
        }
    }
    
    function cancel_vacancy(uint id) public isUserRegistred{
    require(msg.sender == IDList[id].owner);
    if(IDList[id].completed == false){
    //tradeAddress = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    balances[tradeAddress] -= IDList[id].reward;
    balances[msg.sender] += IDList[id].reward * senderCancelRate/100;
    //aworker = 0x583031d1113ad414f02576bd6afabfb302140225;
    balances[aworker] += IDList[id].reward * aworkerCancelRate/100;
    IDList[id].completed = true;
    } else return;
}
}
