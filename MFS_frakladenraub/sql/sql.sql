CREATE TABLE `frakshops` (
  `id` int(11) NOT NULL,
  `fraktion` text NOT NULL DEFAULT 'unbesetzt'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `frakshops` (`id`, `fraktion`) VALUES
(1, 'Vagos'),
(2, 'Vagos'),
(3, 'MG13');

ALTER TABLE `frakshops`
  ADD PRIMARY KEY (`id`);
COMMIT;