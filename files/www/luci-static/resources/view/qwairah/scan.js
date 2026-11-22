'use strict';
'require view';'require fs';'require ui';
return view.extend({
  render:function(){
    var out=E('pre',{id:'qw-scan-out'},_('اضغط فحص 5.8GHz لعرض الشبكات القريبة مرتبة حسب الإشارة.'));
    function doScan(dev,label){
      out.textContent='جاري البحث عن الشبكات في '+label+' ('+dev+')...';
      return fs.exec('/usr/bin/iwinfo',[dev,'scan']).then(function(r){
        out.textContent=(r.stdout||r.stderr||'لا توجد شبكات.').trim();
      }).catch(function(e){out.textContent='خطأ: '+e.message;});
    }
    var b5=E('button',{class:'btn cbi-button-apply',click:function(){return doScan('wlan0','5.8GHz');}},_('فحص 5.8GHz (wlan0)'));
    return E('div',{class:'cbi-map'},[E('h2',{},_('QWAIRAH Channel Scan — فحص قنوات 5.8GHz')),E('div',{class:'cbi-section'},[E('p',{},[b5]),out])]);
  },
  handleSaveApply:null,handleSave:null,handleReset:null
});
