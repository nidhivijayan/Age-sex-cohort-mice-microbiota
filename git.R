system("git --version")
git version 2.50.1 (Apple Git-155)

dir.create("Analysis")
writeLines("# My new analysis notes", "Analysis/notes.md")
system("git add Analysis/notes.md")
system('git commit -m "Add notes.md in Analysis folder"')
system("git push origin main")

writeLines(c(
  "# QIIME Aging Analysis",
  "",
  "This markdown file documents preprocessing and diversity analysis steps."
), "Analysis/qiime-aging.md")

# Remove the Analysis directory from git's cache if it was ignored
system("git rm -r --cached Analysis")

# Then add and commit again
system("git add Analysis/")
system('git commit -m "Add Analysis folder with markdown files"')
system("git push origin main")

system("git status")

print("Checking local files:")
print(list.files("Analysis", recursive = TRUE, all.files = TRUE))
system("git status -- Analysis/")
system("git ls-files")

