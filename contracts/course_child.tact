import "@stdlib/deploy";
import "./messages/course_child";

contract CourseChild with Deployable {
    override const storageReserve: Int = ton("0.1");

    course_address: Address;
    owner: Address;
    owner_iin: String;
    is_initialized: Bool = false;
    
    init(course_address: Address, owner: Address, owner_iin: String) {
        // require(sender() == course_address, "not from collection");
        self.course_address = course_address;
        self.owner = owner;
        self.owner_iin = owner_iin;
    }

    receive("Initialize") {
        require(context().sender == self.course_address, "only parent can initialize");
        self.is_initialized = true;
    }

    receive(msg: SendQuiz) {
        require(context().sender == self.owner, "not from collection");
        require(self.is_initialized, "not initialized");
        send(SendParameters{
            to: msg.quizAddress,
            value: 0,
            bounce: false,
            mode: SendRemainingValue,
            body: msg.answers,
        });
    }

    // receive(msg: GetAnswers) {
    //     require(context().sender = )
    // }

    /////////////////
    //// Getters ////
    /////////////////
    get fun owner_iin(): String {
        return self.owner_iin;
    }

    get fun course_address(): Address {
        return self.course_address;
    }

    get fun is_initialized(): Bool {
        return self.is_initialized;
    }
}
