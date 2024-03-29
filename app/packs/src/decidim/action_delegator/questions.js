$(() => {
  const 
      delegationCallouts = $(".delegation-callout"),
      delegationCalloutsMessage = $(".delegation-callout-message"),
      delegationDialog = $("#delegations-modal"),
      delegationField = $("#decidim_consultations_delegation_id"),
      delegationUnVoteButtons = $(".delegation_unvote_button"),
      delegationVoteButtons = $(".delegation-vote-button"),
      delegationsButton = $("#delegations-button"),
      voteButton = $("#vote_button"),
      voteDialog = $("#question-vote-modal");

  delegationsButton.click(() => {
    delegationDialog.foundation("open");
  });

  delegationVoteButtons.click((evt) => {
    delegationDialog.foundation("close");
    voteDialog.foundation("open");
    delegationField.val($(evt.currentTarget).data("delegation-id"));
    delegationCalloutsMessage.text($(evt.currentTarget).data("delegation-granter-name"));
    delegationCallouts.removeClass("is-hidden");
  });

  delegationUnVoteButtons.click(() => {
    delegationDialog.foundation("close");
    delegationCallouts.addClass("is-hidden");
  });

  voteButton.click(() => {
    delegationCallouts.addClass("is-hidden");
  });
});
