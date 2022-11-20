--
-- Structure de la table `user_clothes`
--

CREATE TABLE `user_clothes` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `clothe` text NOT NULL DEFAULT 'no name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `user_clothes`
--
ALTER TABLE `user_clothes`
  ADD KEY `clothe` (`clothe`(768)),
  ADD KEY `identifier` (`identifier`);
  
