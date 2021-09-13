/*
  Source: https://gist.github.com/albertotb/a47025149ed550a3a3c3525b2da37ee2
*/

remark.macros.scale = function (percentage) {
  var url = this;
  return '<img src="' + url + '" style="width: ' + percentage + '" />';
};

remark.macros.vspace = function (percentage) {
  return `<div style="height: ${percentage}%"></div>`
};

remark.macros.centerScale = function (percentage) {
  var url = this;
  return `<div style="text-align:center;">
            <img src='${url}' style=width: ${percentage}%/>
          </div>`;
};

remark.macros.video = function(width, height) {
  var url = this;
  return `<video width="${width}" height="${height}">
            <source src="${url}" type="video/mp4">
          </video>`
}

remark.macros.colorText = function(color) {
  const text = this;
  return `<span style="color:${color}">${text}</span>`
}
