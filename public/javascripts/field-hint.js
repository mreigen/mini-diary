function setHints() {
  jQuery(".hint").each(function(index) {
    var hint = jQuery(this);
    // ownerId is the id of the input field
    var ownerId = hint.attr("id").replace("-hint", "");
    var owner = jQuery("#" + ownerId);
    var ownerOffset = owner.offset();
    hint.offset({ top: ownerOffset.top + 4, left: ownerOffset.left + owner.width() + 20 });
   
    hint.hide();
    owner.focus(function() {
      hint.show();
    }).blur(function() {
      hint.hide();
    });
  });
}