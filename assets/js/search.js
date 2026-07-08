// Modern command-overlay search logic using Fuse.js
(function () {
  const searchModal = document.getElementById('search-modal');
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-results');
  const searchTrigger = document.getElementById('search-trigger');
  
  let fuseInstance = null;
  let searchDatabase = [];

  // Open modal helper
  function openSearch() {
    if (searchModal) {
      searchModal.classList.add('is-active');
      setTimeout(() => searchInput.focus(), 100);
      document.body.style.overflow = 'hidden'; // Lock background scrolling
      
      // Load search database dynamically if not loaded yet
      if (!fuseInstance) {
        loadSearchData();
      }
    }
  }

  // Close modal helper
  function closeSearch() {
    if (searchModal) {
      searchModal.classList.remove('is-active');
      document.body.style.overflow = ''; // Unlock scrolling
    }
  }

  // Load search index JSON and initialize Fuse.js
  function loadSearchData() {
    const searchUrl = searchTrigger.getAttribute('data-search-url') || '/assets/search.json';
    
    fetch(searchUrl)
      .then(response => response.json())
      .then(data => {
        searchDatabase = data;
        
        // Initialize Fuse.js with fuzzy search configurations
        fuseInstance = new Fuse(searchDatabase, {
          keys: [
            { name: 'title', weight: 0.6 },
            { name: 'tags', weight: 0.2 },
            { name: 'content', weight: 0.2 }
          ],
          threshold: 0.35, // Sensitivity parameter
          ignoreLocation: true
        });
      })
      .catch(err => {
        console.error('Failed to load search index:', err);
        searchResults.innerHTML = '<div class="search-empty-state">⚠️ Error loading search index</div>';
      });
  }

  // Perform search queries
  function executeSearch(query) {
    if (!query.trim()) {
      searchResults.innerHTML = '<div class="search-empty-state">Type to start searching...</div>';
      return;
    }
    
    if (!fuseInstance) {
      searchResults.innerHTML = '<div class="search-empty-state">Initializing search...</div>';
      return;
    }
    
    const results = fuseInstance.search(query).slice(0, 8); // Limit to top 8 matches
    
    if (results.length === 0) {
      searchResults.innerHTML = '<div class="search-empty-state">No results found for "' + escapeHtml(query) + '"</div>';
      return;
    }
    
    let html = '';
    results.forEach(result => {
      const item = result.item;
      const snippet = item.content.slice(0, 140) + '...';
      const tagsHtml = item.tags && item.tags.length > 0 
        ? `<div class="note-tags" style="margin-top:4px;margin-bottom:0;gap:4px;">${item.tags.map(t => `<span class="note-tag" style="font-size:0.65rem;padding:1px 6px;">#${t}</span>`).join('')}</div>`
        : '';
        
      html += `
        <a href="${item.url}" class="search-result-item">
          <div class="search-result-title">${escapeHtml(item.title)}</div>
          <div class="search-result-snippet">${escapeHtml(snippet)}</div>
          ${tagsHtml}
        </a>
      `;
    });
    
    searchResults.innerHTML = html;
  }

  // Helper to escape HTML characters
  function escapeHtml(unsafe) {
    return unsafe
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
  }

  // Keyboard Event Listeners (Command Shortcuts)
  document.addEventListener('keydown', function (e) {
    // Open on '/' or 'Cmd+K' / 'Ctrl+K'
    if ((e.key === '/' && document.activeElement !== searchInput) || 
        ((e.metaKey || e.ctrlKey) && e.key === 'k')) {
      e.preventDefault();
      openSearch();
    }
    
    // Close on Escape
    if (e.key === 'Escape') {
      closeSearch();
    }
  });

  // Modal Header Button Events
  if (searchTrigger) {
    searchTrigger.addEventListener('click', function (e) {
      e.preventDefault();
      openSearch();
    });
  }

  // Modal Background Click Event (close when clicking outside search box)
  if (searchModal) {
    searchModal.addEventListener('click', function (e) {
      if (e.target === searchModal) {
        closeSearch();
      }
    });
  }

  // Text input monitoring
  if (searchInput) {
    searchInput.addEventListener('input', function (e) {
      executeSearch(e.target.value);
    });
  }

})();
