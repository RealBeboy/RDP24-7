if (typeof gPlanTimerExpireAt !== 'undefined') gPlanTimerExpireAt = null;

if (typeof gMainMenu !== 'undefined' && typeof gMainMenu.updateTimer !== 'undefined') {
  if (typeof gMainMenu.updateTimer === 'number') {
    gMainMenu.updateTimer = 0; // Disable countdown by setting to zero
  } else {
    console.warn('gMainMenu.updateTimer is not a number');
  }
}

// Remove all intervals stored in variables, assuming you can access them here
if (typeof A !== 'undefined') clearInterval(A);
if (typeof a !== 'undefined') clearInterval(a);

// Disable any countdown or session timeout functions if known
if (typeof sessionReset === 'function') sessionReset = function() {};
if (typeof sessionStartQueue === 'function') sessionStartQueue = function() {};
if (typeof sessionResumeDirect === 'function') sessionResumeDirect = function() {};
if (typeof sessionResumeOrStartQueue === 'function') sessionResumeOrStartQueue = function() {};

// Clear any existing timeout or intervals by enumerating possible timer IDs
let maxTimerId = setTimeout(() => {}, 0);
for (let i = 0; i < maxTimerId; i++) {
  clearTimeout(i);
  clearInterval(i);
}

// Additional disabling for event listeners for timers if needed
window.addEventListener = function() {};
document.addEventListener = function() {};
