document.querySelectorAll('button').forEach(btn => {
  btn.addEventListener('click', () => {
    btn.textContent = 'Added!';
    btn.style.background = '#1D9E75';
    setTimeout(() => {
      btn.textContent = 'Add to cart';
      btn.style.background = '';
    }, 1500);
  });
});
