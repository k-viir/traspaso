/* eslint-disable no-unused-expressions */
({
  doInit: function(cmp, evt, helper) {
    console.log('me');
  },
  handleLeft: function(cmp, evt, helper) {
    let leftButton = cmp.find('leftButton');
    let chartPosition = cmp.get('v.chartPosition');
    let calculatedTranslate = (chartPosition - 1) * 33.33;
    let rightButton = cmp.find('rightButton');
    rightButton.set('v.disabled', false);
    let wrapper = cmp.find('componentWrapper');
    wrapper.getElement().style.transform = 'translateX(-' + calculatedTranslate.toString() + '%)';
    cmp.set('v.chartPosition', chartPosition - 1);
    if (chartPosition - 1 === 0) {
      leftButton.set('v.disabled', true);
    }
  },
  handleRight: function(cmp, evt, helper) {
    let rightButton = cmp.find('rightButton');
    let chartPosition = cmp.get('v.chartPosition');
    let chartCount = cmp.get('v.chartCount');
    let calculatedTranslate = (chartPosition + 1) * 33.33;
    let leftButton = cmp.find('leftButton');
    leftButton.set('v.disabled', false);
    let wrapper = cmp.find('componentWrapper');
    wrapper.getElement().style.transform = 'translateX(-' + calculatedTranslate.toString() + '%)';
    cmp.set('v.chartPosition', chartPosition + 1);
    if (chartPosition + 1 === (chartCount - 1)) {
      rightButton.set('v.disabled', true);
    }
  }
});
