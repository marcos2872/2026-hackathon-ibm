import type * as React from 'react';
export type IconName = 'moeda' | 'xp' | 'trofeu' | 'tela' | 'camera' | 'check' | 'ampulheta' | 'bau' | 'vassoura' | 'casa' | 'balde' | 'louca' | 'd20';
export type Counter = 'creditos' | 'xp' | 'temporada' | 'tela';
export type RecordStatus = 'pendente' | 'aprovado' | 'rejeitado' | 'contestado';
export interface IconProps { name: IconName; size?: 12 | 24 | 36 | 48 | 16 | 32; title?: string; className?: string }
export declare function Icon(props: IconProps): React.ReactElement;
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> { variant?: 'primary' | 'secondary' | 'blue' | 'danger' | 'ghost'; size?: 'md' | 'sm'; icon?: IconName }
export declare function Button(props: ButtonProps): React.ReactElement;
export interface PanelProps { title?: string; icon?: IconName; tone?: 'blue' | 'red' | 'gold'; action?: React.ReactNode; children?: React.ReactNode }
export declare function Panel(props: PanelProps): React.ReactElement;
export interface StatusBadgeProps { status: RecordStatus; children?: React.ReactNode }
export declare function StatusBadge(props: StatusBadgeProps): React.ReactElement;
export interface CounterChipProps { kind: Counter; value: number | string }
export declare function CounterChip(props: CounterChipProps): React.ReactElement;
export interface StatBarProps { kind: Counter; value: number; max: number; segments?: number; label?: string; display?: string }
export declare function StatBar(props: StatBarProps): React.ReactElement;
export interface HeroHeaderProps { name: string; level: number; role?: string; avatar?: IconName; xp: number; xpMax?: number; screen?: number; screenMax?: number; credits?: number; season?: number; streak?: number }
export declare function HeroHeader(props: HeroHeaderProps): React.ReactElement;
export interface QuestItemProps { title: string; icon?: IconName; weight: 0.5 | 1 | 2 | 3 | number; points: number; evidence?: 'antes-depois' | 'depois' | 'nenhuma'; due?: string; status?: 'aberta' | RecordStatus; onRegister?: () => void }
export declare function QuestItem(props: QuestItemProps): React.ReactElement;
export interface RewardCardProps { title: string; icon?: IconName; cost: number; horizon?: 'curto' | 'medio' | 'longo'; balance?: number; stock?: number; onRedeem?: () => void }
export declare function RewardCard(props: RewardCardProps): React.ReactElement;
export interface RankingRowProps { position: number; name: string; level: number; points: number; me?: boolean }
export declare function RankingRow(props: RankingRowProps): React.ReactElement;
export interface GoalProgressProps { title: string; target: number; minShare?: number; deadline?: string; icon?: IconName; members: { name: string; value: number }[] }
export declare function GoalProgress(props: GoalProgressProps): React.ReactElement;
export interface DialogBoxProps { title?: string; icon?: IconName; action?: React.ReactNode; children?: React.ReactNode }
export declare function DialogBox(props: DialogBoxProps): React.ReactElement;
export interface TabBarProps { items?: { id: string; label: string; icon: IconName; badge?: number }[]; active: string; onChange?: (id: string) => void }
export declare function TabBar(props: TabBarProps): React.ReactElement;
export declare function QuestScreen(): React.ReactElement;
declare global { interface Window { CasaQuest: { Icon: typeof Icon; Button: typeof Button; Panel: typeof Panel; StatusBadge: typeof StatusBadge; CounterChip: typeof CounterChip; StatBar: typeof StatBar; HeroHeader: typeof HeroHeader; QuestItem: typeof QuestItem; RewardCard: typeof RewardCard; RankingRow: typeof RankingRow; GoalProgress: typeof GoalProgress; DialogBox: typeof DialogBox; TabBar: typeof TabBar; QuestScreen: typeof QuestScreen; sprites: Record<IconName, string[]> } } }
