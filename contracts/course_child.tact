import "@stdlib/deploy";
import "./messages/course_child";

contract CourseChild with Deployable {
    override const storageReserve: Int = ton("0.2");

    courseAddress: Address;
    owner: Address;
    // Cell which will save beginParse().saveUint([0-9], 4)....endParse(); 
    // 12 digit because IIN 12 DIgit 48 bit < 96 bit(string representation)
    ownerIin: String; 
    isInitialized: Bool = false;
    
    init(courseAddress: Address, owner: Address, ownerIin: String) {
        require(courseAddress == context().sender, "Ty che morosish bratishka");
        self.courseAddress = courseAddress;
        self.owner = owner;
        self.ownerIin = ownerIin;
    }

    receive("Initialize") {
        require(context().sender == self.courseAddress, "only parent can initialize");
        self.isInitialized = true;
    }

    receive(msg: SendAnswer) {
        require(context().sender == self.owner, "not from collection");
        require(self.isInitialized, "not initialized");
        send(SendParameters{
            to: msg.quizAddress,
            value: 0,
            bounce: false,
            mode: SendRemainingValue,
            body: StudentAnswer{studentIin: self.ownerIin, 
                                studentAddress: self.owner, 
                                studentAnswers: msg.answer}.toCell(),
        });
    }

    receive(msg: Result) {

        emit(Result{quizId: msg.quizId, percent: msg.percent}.toCell());
    }

    // receive(msg: GetAnswers) {
    //     require(context().sender = )
    // }

    /////////////////
    //// Getters ////
    /////////////////
    get fun ownerIin(): String {
        return self.ownerIin;
    }

    get fun courseAddress(): Address {
        return self.courseAddress;
    }

    get fun isInitialized(): Bool {
        return self.isInitialized;
    }
}
