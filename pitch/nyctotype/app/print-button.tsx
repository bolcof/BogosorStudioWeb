'use client';
import { Printer } from 'lucide-react';
export function PrintButton() {
  return <button className="print-button" type="button" onClick={() => window.print()} aria-label="ピッチを印刷・PDF保存" title="印刷・PDF保存"><Printer size={19} /></button>;
}
