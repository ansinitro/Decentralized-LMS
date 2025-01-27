import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages/course_parent";
import "./course_child";

contract CourseParent with Deployable, Ownable {
    override const storageReserve: Int = ton("0.1");

    owner: Address;
    id: Int as uint32;
    cost: Int as coins = ton("256");
    gasOverhead: Int as uint32 = ton("0.5"); // Configurable gas overhead
    studentsNumber: Int as uint32 = 0;

    // Initialize the contract
    init(courseOwner: Address, id: Int) {
        require(id >= 0, "Invalid course ID");
        require(courseOwner == context().sender,"Ty che morosish bratishka");
        self.owner = courseOwner;
        self.id = id;
    }

    // Receive a message to update course cost
    receive(msg: CostChange) {
        self.requireOwner(); // Ensure only the owner can update the cost
        require(msg.newCost > 0, "Cost must be positive");
        self.cost = msg.newCost;
        emit(CostChange{newCost: msg.newCost}.toCell());
    }

    // Receive a message to update gas overhead
    receive(msg: UpdateGasOverhead) {
        self.requireOwner(); // Ensure only the owner can update gas overhead
        require(msg.newGasOverhead > 0, "Gas overhead must be positive");
        self.gasOverhead = msg.newGasOverhead;
            UpdateGasOverhead{newGasOverhead: msg.newGasOverhead}.toCell();
    }

    // Handle student enrollment
    receive(msg: Enrollment) {
        let tonBefore = myBalance() - context().value;
        let ctx = context();

        // Ensure the sender has sent enough funds
        require(ctx.value >= self.cost + self.gasOverhead, "Not enough funds to enroll");

        // Get Jetton wallet initialization details
        let winit: StateInit = self.getJettonWalletInit(ctx.sender, msg.studentIin);

        // Increment the number of students
        self.studentsNumber += 1;

        // Initialize the student's wallet
        send(SendParameters{
            to: contractAddress(winit),
            value: ton("0.1"),
            bounce: false,
            mode: SendPayGasSeparately,
            body: "Initialize".asComment(),
            code: winit.code,
            data: winit.data
        });

        // Emit an enrollment event
        emit(EnrollmentEmit{studentIin: msg.studentIin, studentAddress: ctx.sender}.toCell());

        // Reserve necessary funds and refund any excess
        nativeReserve(tonBefore + self.storageReserve + self.cost, 0);
        send(SendParameters{
            value: 0,
            mode: SendRemainingBalance,
            to: ctx.sender,
            bounce: false,
            body: "You have successfully enrolled to the course!".asComment()
        });
    }

    // Withdraw funds from the contract
    receive("Withdraw") {
        self.requireOwner(); // Ensure only the owner can withdraw funds
        nativeReserve(self.storageReserve, 0); // Keep storage reserve intact
        send(SendParameters{
            value: 0,
            mode: SendRemainingBalance,
            to: self.owner,
            bounce: false,
            body: "Withdraw completed".asComment()
        });
    }

    // Get Jetton wallet initialization details
    fun getJettonWalletInit(sender: Address, iin: String): StateInit {
        return initOf CourseChild(myAddress(), sender, iin);
    }

    /////////////////
    //// Getters ////
    /////////////////

    get fun courseId(): Int {
        return self.id;
    }

    get fun courseCost(): Int {
        return self.cost;
    }

    get fun gasOverhead(): Int {
        return self.gasOverhead;
    }

    get fun studentsNumber(): Int {
        return self.studentsNumber;
    }

    get fun balance(): Int {
        return myBalance();
    }
}

    //  receive("Destroy") {
    //     self.requireOwner();
    //     send(SendParameters{
    //         value: 0, 
    //         mode: SendRemainingBalance | SendDestroyIfZero,
    //         to: self.owner, 
    //         bounce: false,
    //         body: "Contract destroyed".asComment()
    //     });
    // }