export const getScrollTop = function(element) {
  return function() {
    return element.scrollTop;
  };
};

export const getClientHeight = function(element) {
  return function() {
    return element.clientHeight;
  };
};

export const scrollToPosition = function(scrollTop) {
  return function() {
    const listElement = document.querySelector('.customer-list');
    if (listElement) {
      listElement.scrollTo({
        top: scrollTop,
        behavior: 'smooth'
      });
    }
  };
};
