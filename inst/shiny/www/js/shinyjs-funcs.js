shinyjs.scrollLogger = function(params) {
  var $logger = $('#messageLog');
  $logger.scrollTop($logger[0].scrollHeight);
}

shinyjs.disableModule = function(params) {
  var defaultParams = {
    component : null,
    module : null
  }
  params = shinyjs.getParams(params, defaultParams);
  params.shinymod = params.component;
  params.component = params.component + "Sel";
  var $radio = $("input[type='radio'][name='" + params.component + "']" +
    "[value='" + params.shinymod + "_" + params.module + "']");
  var checked = $radio.prop('checked');
  $radio.attr("disabled", true);
  $radio.closest(".radio").addClass("disabled");

  // If disabling a selected radio button, select the next enabled one
  if (checked) {
    var $parent = $radio.closest(".shiny-input-radiogroup");
    $parent.find(".radio input[type='radio']:enabled").first().prop('checked', true);
    $parent.trigger("change");
  }
}

shinyjs.enableModule = function(params) {
  var defaultParams = {
    component : null,
    module : null
  }
  params = shinyjs.getParams(params, defaultParams);
  params.shinymod = params.component;
  params.component = params.component + "Sel";
  var $radio = $("input[type='radio'][name='" + params.component + "']" +
    "[value='" + params.shinymod + "_" + params.module + "']");
  $radio.attr("disabled", false);
  $radio.closest(".radio").removeClass("disabled");
}

shinyjs.runOnEnter = function(params) {
  $(document).off('keydown.runOnEnter');
  $(document).on('keydown.runOnEnter', function(e) {
    if (e.key === 'Enter' || e.keyCode === 13) {
      // Check if a shinyalert modal is open
      const isModalOpen = $('.sweet-alert:visible').length > 0;
      if (!isModalOpen) {
        const button = document.getElementById(`${params}-run`)
        if (button) {
          button.click();
        }
      }
    }
  });
}
