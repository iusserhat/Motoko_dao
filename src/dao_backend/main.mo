import Array "mo:base/Array";
import type {Proposal, Member, ProposalStatus};

actor DAO {
    private var members: [Member] = [];
    private var proposals: [Proposal] = [];
    private var votes: [(Nat, Nat, Bool)] = []; // (ProposalID, MemberID, Vote)

    public func addMember(newMember: Member) {
        // Yeni üye ekler.
        members := Array.append<Member>(members, [newMember]);
    }

    public func createProposal(newProposal: Proposal) {
        // Yeni teklif ekler.
        proposals := Array.append<Proposal>(proposals, [newProposal]);
    }

    public func vote(proposalId: Nat, memberId: Nat, vote: Bool) : Async<()> {
        // Belirli bir teklife oy verir. Üyenin oylama yetkisi kontrol edilir.
        let memberExists = Array.find<Member>(members, func(m) : Bool { m.id == memberId }) != null;
        let proposalIndex = Array.find<(Proposal, Nat)>(proposals, func(p, i) : Bool { p.id == proposalId });

        if (memberExists and (proposalIndex != null)) {
            let (_, index) = proposalIndex.unwrap();
            let currentProposal = proposals[index];
            if (currentProposal.status == #Open) {
                votes := Array.append<(Nat, Nat, Bool)>(votes, [(proposalId, memberId, vote)]);
                checkProposalStatus(proposalId);
            }
        }
    }

    private func checkProposalStatus(proposalId: Nat) {
        // Bir teklifin durumunu kontrol eder ve gerekirse günceller.
        let relevantVotes = Array.filter<(Nat, Nat, Bool)>(votes, func(v) : Bool { v.0 == proposalId });
        let positiveVotes = Array.filter<(Nat, Nat, Bool)>(relevantVotes, func(v) : Bool { v.2 }).size();

        let proposalIndex = Array.find<(Proposal, Nat)>(proposals, func(p, i) : Bool { p.id == proposalId }).unwrap().1;
        let currentProposal = proposals[proposalIndex];

        // Basit bir çoğunluk kararı alınır: Oyların yarısından fazlası olumlu ise teklif kabul edilir.
        if (positiveVotes > (relevantVotes.size() / 2)) {
            proposals[proposalIndex] := {
                currentProposal with status = #Accepted;
            };
        } else if (positiveVotes <= (relevantVotes.size() / 2) and relevantVotes.size() == members.size()) {
            // Tüm üyeler oy kullanmış ve çoğunluk sağlanamamışsa, teklif reddedilir.
            proposals[proposalIndex] := {
                currentProposal with status = #Rejected;
            };
        }
    }

    public func getProposals() : Async<[Proposal]> {
        // Tüm teklifleri döndürür.
        return proposals;
    }

    public func getMembers() : Async<[Member]> {
        // Tüm üyeleri döndürür.
        return members;
    }
}

