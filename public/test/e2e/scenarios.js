'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Subout App', function() {

  it('should redirect index.html to index.html#/dashboard', function() {
    browser().navigateTo('/index.html');
    expect(browser().location().url()).toBe('/dashboard');
  });
  
});
