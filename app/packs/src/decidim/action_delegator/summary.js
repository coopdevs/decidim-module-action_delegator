$(() => {
  const $usersAnswers = $("#user-answers-summary");
  const path = $usersAnswers.data("summaryPath");
  let $button = $("#consultations-questions-summary-button");
  let $modal = $("#consultations-questions-summary-modal");
  const $div = $(".question-vote-cabin").parent();
  const openModal = (evt) => {
    evt.preventDefault();
    $modal.foundation("open");    
  };

  $button.on("click", openModal);

  $div.bind("DOMSubtreeModified", function() {
    // console.log("tree changed", path);
    $usersAnswers.load(path, () => {
      $button = $usersAnswers.find("#consultations-questions-summary-button");
      $modal = $usersAnswers.find("#consultations-questions-summary-modal");
      // console.log("usersanswer loaded")
      $usersAnswers.foundation();
      $button.on("click", openModal);
    });
  });
});
