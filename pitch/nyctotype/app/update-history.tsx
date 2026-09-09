'use client';

import { useRef } from 'react';
import { X } from 'lucide-react';
import updates from './update-history.json';

export function UpdateHistory() {
  const dialog = useRef<HTMLDialogElement>(null);
  const latest = updates[0].date;

  return <div className="update-history">
    <button type="button" className="history-trigger" data-open-dialog="update-history-dialog" aria-label={`${latest.replaceAll('-', '.')} 更新履歴を表示`} title="更新履歴を表示" aria-haspopup="dialog" aria-controls="update-history-dialog" onClick={() => dialog.current?.showModal()}>
      <span><time dateTime={latest}>{latest.replaceAll('-', '.')}</time> update</span>
    </button>
    <dialog id="update-history-dialog" className="history-dialog" ref={dialog} aria-labelledby="update-history-title" data-dismiss-backdrop="true" onClick={event => {
      if (event.target !== event.currentTarget) return;
      const bounds = event.currentTarget.getBoundingClientRect();
      if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) event.currentTarget.close();
    }}>
      <header className="history-header">
        <h2 id="update-history-title">更新履歴</h2>
        <form method="dialog"><button type="submit" className="history-close" aria-label="更新履歴を閉じる" title="閉じる" autoFocus><X size={22} aria-hidden="true"/></button></form>
      </header>
      <ol className="history-list">
        {updates.map(update => <li key={update.date}>
          <h3><time dateTime={update.date}>{update.date.replaceAll('-', '.')}</time></h3>
          <ul>{update.changes.map(change => <li key={change}>{change}</li>)}</ul>
        </li>)}
      </ol>
    </dialog>
  </div>;
}
