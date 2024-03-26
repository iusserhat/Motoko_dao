// type.mo
module {
  public type Member = {
    id: Nat;
    name: Text;
    address: Text;
  };

  public type Proposal = {
    id: Nat;
    description: Text;
    amount: Nat;
    voteCount: Nat;
    status: ProposalStatus;
  };

  public type ProposalStatus = {
    #Open;
    #Closed;
    #Accepted;
    #Rejected;
  };
};
