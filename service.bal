import ballerina/http;
import ballerina/log;

configurable string botUrl = ?;
final http:Client telegramClient = check new (botUrl);

service /myagent on new http:Listener(8080) {
    isolated resource function post message(TelegramMessage telegramMessage) returns error? {
        log:printInfo("Message recieved. Processing data....");
        string answer = check agent->run(telegramMessage.message.text);
        log:printInfo(string `Answer from agent: ${answer}`);
        json reply = {chat_id: telegramMessage.message.chat.id.toString(), text: answer};
        http:Response _ = check telegramClient->/sendMessage.post(reply);
    }
}

type From record {
    int id;
    boolean is_bot;
    string first_name;
    string username?;
    string language_code;
};

type Chat record {
    int id;
    string first_name;
    string username?;
    string 'type;
};

type Message record {
    int message_id;
    From 'from;
    Chat chat;
    int date;
    string text;
};

type TelegramMessage record {
    int update_id;
    Message message;
};
