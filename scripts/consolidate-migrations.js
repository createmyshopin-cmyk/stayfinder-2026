#!/usr/bin/env node
/**
 * Consolidates all supabase/migrations/*.sql into a single file for manual run.
 * Usage: node scripts/consolidate-migrations.js
 * Output: supabase/FULL_MIGRATION.sql
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const migrationsDir = path.join(__dirname, "..", "supabase", "migrations");
const outputPath = path.join(__dirname, "..", "supabase", "FULL_MIGRATION.sql");

const files = fs.readdirSync(migrationsDir)
  .filter((f) => f.endsWith(".sql"))
  .sort();

let out = `-- STAY UI: Consolidated migration (${files.length} files)\n`;
out += `-- Run this in Supabase SQL Editor if CLI is not an option\n`;
out += `-- Project: rqnxtcigfauzzjaqxzut\n`;
out += `-- Generated: ${new Date().toISOString()}\n\n`;

for (const f of files) {
  out += `\n-- ========== ${f} ==========\n`;
  out += fs.readFileSync(path.join(migrationsDir, f), "utf8");
  out += "\n";
}

fs.writeFileSync(outputPath, out, "utf8");
console.log(`Written: ${outputPath} (${files.length} migrations)`);
