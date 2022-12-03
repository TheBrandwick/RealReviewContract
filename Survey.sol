ragma solidity >=0.7.0 <0.9.0;

/** 
 * @title RealReview
 * @dev Implements voting process along with vote delegation
 */
contract RealReview {

    struct Survey {
        mapping(address => Participant) participants;
        uint256 id;
        address creator;
        uint256 max_participants_count;
        uint256 current_participants_count;
        uint256 reward_per_participant;
        uint256 valid_until;
        bool is_draft;
        bool is_active;
        string form_uri;
    }
    struct Participant {
        uint256 id;
        address participant_address;
        uint256 user_id;
        uint256 survey_id;
        bool completed;
        bool rewarded;
        string form_submission_uri;
    }
    struct User {
        uint256 id;
        address wallet_address;
        string first_name;
        string last_name;
        string email;
        string profile_pic;
        uint256 survey_created_count;
        uint256 survey_attempted_count;
        uint256 total_reward_earned;
        uint256 total_amount_spent;
        address funds_locker_address;
    }
    Survey[] public surveys;
    mapping(address => User) users;

    // function getSurveys() public view returns (Survey[] memory) {
    //     return surveys;
    // }

    function createSurvey(
        uint256 max_participants_count,
        uint256 reward_per_participant,
        uint256 valid_until,
        bool is_draft,
        bool is_active,
        string memory form_uri
    ) public payable {
        // uint256 amount_to_deposit = reward_per_participant * max_participants_count;
        // require(msg.value == amount_to_deposit, "Less ether recieved than required." );
        Survey storage newSurvey = surveys.push();
        newSurvey.id= surveys.length;
        newSurvey.creator= msg.sender;
        newSurvey.max_participants_count= max_participants_count;
        newSurvey.current_participants_count= 0;
        newSurvey.reward_per_participant= reward_per_participant;
        newSurvey.valid_until= valid_until;
        newSurvey.is_draft= is_draft;
        newSurvey.is_active= is_active;
        newSurvey.form_uri= form_uri;
    }
    function updateSurvey() public {

    }
    function participateSurvey(uint256 survey_index, uint256 user_id) public {
        Survey storage target_survey = surveys[survey_index];
        // check if participant slot left
        Participant memory new_participant;
        new_participant.id = target_survey.current_participants_count;
        new_participant.participant_address = msg.sender;
        new_participant.user_id = user_id;
        new_participant.survey_id = survey_index;
        new_participant.completed = false;
        new_participant.rewarded = false;

        target_survey.participants[msg.sender] = new_participant;
    }
    function submitSurvey(uint256 survey_index, string memory form_submission_uri) public {
        Survey storage target_survey = surveys[survey_index];
        // check if participated or not
        target_survey.participants[msg.sender].form_submission_uri = form_submission_uri;
        target_survey.participants[msg.sender].completed = true;
    }
    function claimReward(uint256 survey_index) public payable {
        Survey storage target_survey = surveys[survey_index];
        // check if the user has participated and submitted
        sendReward(msg.sender, target_survey.reward_per_participant);
        target_survey.participants[msg.sender].rewarded = true;

    }
    function sendReward(address to, uint value) private {
        address payable receiver = payable(to);
        receiver.transfer(value);
    }
}
