import "@stdlib/deploy";
import "./messages/quiz";
import "@stdlib/ownable";

contract Quiz with Deployable, Ownable {
    override const storageReserve: Int = ton("0.1");

    id: Int;
    course_address: Address;
    answers: Slice;
    owner: Address;
    open: Bool = true;

    init(id: Int, course_address: Address, answers: Slice) {
        self.id = id;
        self.course_address = course_address;
        self.answers = answers;
        self.owner = context().sender
    }

    receive(msg: Answers) {
        require(( && self.open) || context().sender == self.owner, "The quize ended");
        emit(EmitAnswers{sender: context().sender, answers: msg.answers}.toCell());

        // send(SendParameters{
        //     to: context().sender,
        //     value: 0,
        //     bounce: false,
        //     mode: SendRemainingValue,
            // body: percent.toString().asComment(),
        // });
    }

    receive("Lock") {
        self.requireOwner();
        emit("Lock".asComment());
        self.open = true;
    }

    receive("Unlock") {
        self.requireOwner();
        self.open = false;
    }

    fun getJettonWalletInit(sender: Address, IIN: String): StateInit {
        return initOf CourseChild(myAddress(), sender, IIN);
    }
    
    /////////////////
    //// Getters ////
    ////////////////
    get fun id(): Int {
        return self.id;
    }

    get fun open(): Int {
        return self.id;
    }

    get fun course_address(): Address {
        return self.course_address;
    }
}

        // quiz = blockchain
        //     .openContract(await Quiz.fromInit(0n, courseParent.address, beginCell()
        //         .storeUint(1, 3)
        //         .storeUint(3, 3)
        //         .storeUint(4, 3)
        //         .storeUint(2, 3)
        //         .storeUint(1, 3)
        //         .asSlice()));