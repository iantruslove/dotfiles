(require 'org-table)
(require 'org-clock)


;; Creates a clocktable organized by tags.
;;
;; Pop something like this into an org file:
;;
;;   #+BEGIN: clocktable-by-tag :tags ("a" "b" "c" "-a-b-c") :block today :maxlevel 1
;;   #+END:
;;


(defmacro plist-puts (plist &rest args)
  (let ((list nil))
    (while args
      (push `(setq ,plist (plist-put ,plist ,(pop args) ,(pop args))) list))
    (cons 'progn (nreverse list))))

(defun clocktable-by-tag/shift-cell (n)
  (let ((str ""))
    (dotimes (i n)
      (setq str (concat str "| ")))
    str))

(defun clocktable-by-tag/insert-tag (params)
  (let ((tag (plist-get params :tags)))
    (insert "|--\n")
    (insert (format "| %s | *Tag time* |\n" tag))
    (let ((total 0))
      (mapcar
       (lambda (file)
         (let ((clock-data (with-current-buffer (find-file-noselect file)
                             (org-clock-get-table-data (buffer-name) params))))
           (when (> (nth 1 clock-data) 0)
             (setq total (+ total (nth 1 clock-data)))
             (insert (format "| | File *%s* | %.2f |\n"
                             (file-name-nondirectory file)
                             (/ (nth 1 clock-data) 60.0)))
             ;; (dolist (entry (nth 2 clock-data))
             ;;   (insert (format "| | . %s%s | %s %.2f |\n"
             ;;                   (org-clocktable-indent-string (nth 0 entry))
             ;;                   (nth 1 entry)
             ;;                   (clocktable-by-tag/shift-cell (nth 0 entry))
             ;;                   (/ 60
             ;;                      ;; (nth 3 entry)
             ;;                      60.0))))
             )))
       (org-agenda-files))
      (save-excursion
        (re-search-backward "*Tag time*")
        (org-table-next-field)
        (org-table-blank-field)
        (insert (format "*%.2f*" (/ total 60.0)))))
    (org-table-align)))

(defun org-dblock-write:clocktable-by-tag (params)
  (insert "| Tag | Headline | Time (h) |\n")
  (insert "|     |          | <r>  |\n")
  (let ((tags (plist-get params :tags)))
    (mapcar (lambda (tag)
              (setq params (plist-puts params
                                       :tags tag
                                       :match tag
                                       :tcolumn 1))
              (clocktable-by-tag/insert-tag params))
            tags)))

(provide 'org-clocktable-by-tag)
